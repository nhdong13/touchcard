require "rails_helper"

RSpec.describe WebhookController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let!(:shop) { create(:shop, credit: 2) }
  let!(:card_order) { create(:card_order, shop: shop) }
  let(:order) { create(:order) }

  def stub_order(key, overrides={})
    order_text = File.read(
      "#{Rails.root}/spec/fixtures/shopify/orders/show/#{key}.json")
    order_obj = JSON.parse(order_text).with_indifferent_access
    order_obj.merge!(overrides)
    stub_request(:get, "https://#{shop.domain}/admin/orders/#{order_obj[:order][:id]}.json")
      .to_return(body: order_obj[:order].to_json)
    order_obj[:order]
  end

  def set_auth_header(params)
    digest = OpenSSL::Digest.new("sha256")
    api_secret = ENV["SHOPIFY_CLIENT_API_SECRET"]
    digested = OpenSSL::HMAC.digest(digest, api_secret, params.to_query)
    @request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"] = Base64.encode64(digested).strip
  end

  def set_domain_header(shop)
    @request.headers["X-Shopify-Shop-Domain"] = shop.domain
  end

  def post_new_order(params)
    set_auth_header(params)
    set_domain_header(shop)
    post :new_order, params
  end

  describe "#new_order" do
    context "already exists" do
      it "ignores" do
        post_new_order(id: order.shopify_id)
        expect(response.status).to eq 200
        expect(Customer.count).to eq 0
        expect(Postcard.count).to eq 0
        expect(Order.count).to eq 1
      end
    end

    context "no customer" do
      it "saves order but not postcard" do
        s_order = stub_order("no_customer")
        post_new_order(id: s_order[:id])
        expect(response.status).to eq 200
        expect(Customer.count).to eq 0
        expect(Postcard.count).to eq 0
        expect(Order.count).to eq 1
      end
    end

    context "has customer" do
      context "no default address" do
        it "saves order but not postcard" do
          s_order = stub_order("no_default_address")
          post_new_order(id: s_order[:id])
          expect(response.status).to eq 200
          expect(Customer.count).to eq 1
          expect(Address.count).to eq 0
          expect(Postcard.count).to eq 0
          expect(Order.count).to eq 1
        end
      end

      context "who is new" do
        let(:s_order) { stub_order("everything") }
        before(:each) { post_new_order(id: s_order[:id]) }

        context "vaild card order" do
          it "creates postcard" do
            expect(Postcard.count).to eq 1
          end
        end

        it "creates customer" do
          expect(Customer.count).to eq 1
        end

        it "creates customer address" do
          expect(Address.count).to eq 1
        end
      end

      context "who is not new" do
        # TODO change this to using a customer with 2 orders
        let(:s_order) { stub_order("everything") }

        context "and discount code exists on postcard"  do
          let!(:postcard) do
            create(:postcard,
              discount_code: s_order[:discount_codes].first[:code])
          end

          it "connects order to postcard" do
            post_new_order(id: s_order[:id])
            expect(Order.last.postcard.id).to eq(postcard.id)
            expect(postcard.card_order.revenue).to eq 40994
            expect(postcard.shop.revenue).to eq 40994
          end
        end

        context "and exists in db" do
          let!(:customer) do
            create(:customer, shopify_id: s_order[:customer][:id])
          end

          it "updates the customer data" do
            post_new_order(id: s_order[:id])
            expected = s_order[:customer].slice(:email, :first_name, :last_name)
            expect(Customer.first.attributes).to include(expected)
          end
        end

        context "and has been sent a postcard" do
          let!(:customer) do
            create(:customer, shopify_id: s_order[:customer][:id])
          end
          let!(:postcard) { create(:postcard, order: order, customer: customer) }
          before(:each) { order.update_attributes!(customer: customer) }
          it "connects order to postcard" do
            post_new_order(id: s_order[:id])
            new_order = Order.find_by(shopify_id: s_order[:id])
            expect(new_order.postcard_id).to eq(postcard.id)
            expect(postcard.card_order.revenue).to eq 40994
            expect(postcard.shop.revenue).to eq 40994
          end
        end
      end
    end # /has customer
  end
end
