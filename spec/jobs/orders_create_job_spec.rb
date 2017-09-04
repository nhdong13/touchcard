require 'rails_helper'

RSpec.describe OrdersCreateJob, type: :job do
  include ActiveJob::TestHelper

  def stub_order(key, overrides={})
    order_text = File.read(
      "#{Rails.root}/spec/fixtures/shopify/orders/show/#{key}.json")
    order_obj = JSON.parse(order_text).with_indifferent_access
    order_obj.merge!(overrides)
    stub_request(:get, "https://#{shop.domain}/admin/orders/#{order_obj[:order][:id]}.json")
      .to_return(body: order_obj[:order].to_json)
    order_obj[:order]
  end

  let!(:shop) { create(:shop, credit: 2) }
  let!(:card_order) { create(:card_order, shop: shop) }
  let(:order) { create(:order) }
  subject(:job) do
    webhook_text = File.read("#{Rails.root}/spec/fixtures/shopify/webhooks/orders_create.json")
    webhook_obj = JSON.parse(webhook_text).with_indifferent_access
    described_class.perform_later(shop_domain: shop.domain, webhook: webhook_obj)
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(OrdersCreateJob.new.queue_name).to eq('default')
  end

  describe "#perform" do
    context "order already exists" do
      it "ignores" do
        stub_order("no_customer")
        perform_enqueued_jobs { job }
        expect(Customer.count).to eq 0
        expect(Postcard.count).to eq 0
        expect(Order.count).to eq 1
      end
    end

    context "order has customer" do
      context "without default address" do
        it "saves order but not postcard" do
          stub_order("no_default_address")
          perform_enqueued_jobs { job }
          expect(Customer.count).to eq 1
          expect(Address.count).to eq 0
          expect(Postcard.count).to eq 0
          expect(Order.count).to eq 1
        end
      end

      context "who is new" do

        context "valid card order" do
          it "creates postcard" do
            stub_order("everything")
            perform_enqueued_jobs { job }

            expect(Postcard.count).to eq 1
          end

          it "deducts shop credits" do
            stub_order("everything")
            perform_enqueued_jobs { job }

            expect(Shop.find(shop.id).credit).to eq shop.credit - 1
          end
        end

        context "no street in address" do
          it "saves order but doesn't create postcard" do
            stub_order("no_street_in_address")
            perform_enqueued_jobs { job }
            expect(Customer.count).to eq 1
            expect(Address.count).to eq 1
            expect(Postcard.count).to eq 0
            expect(Order.count).to eq 1
          end
        end

        context "shop not enough credits" do
          before(:each) { shop.update_attributes(credit: 0) }

          it "doesn't create postcard" do
            stub_order("everything")
            perform_enqueued_jobs { job }

            expect(Postcard.count).to eq 0
          end

          it "doesn't deducts shop credits" do
            stub_order("everything")
            perform_enqueued_jobs { job }

            expect(Shop.find(shop.id).credit).to eq shop.credit
          end
        end

        it "creates customer" do
          stub_order("everything")
          perform_enqueued_jobs { job }

          expect(Customer.count).to eq 1
        end

        it "creates customer address" do
          stub_order("everything")
          perform_enqueued_jobs { job }

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
            perform_enqueued_jobs { job }
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
            perform_enqueued_jobs { job }
            expected = s_order[:customer].slice(:email, :first_name, :last_name)
            expect(Customer.first.attributes).to include(expected)
          end
        end

        context "and has been sent a postcard" do
          let!(:customer) do
            create(:customer, shopify_id: s_order[:customer][:id])
          end
          let!(:postcard) { create(:postcard, discount_code: 'TENOFF',
                                    order: order, customer: customer) }
          before(:each) { order.update_attributes!(customer: customer) }
          it "connects order to postcard" do
            perform_enqueued_jobs { job }
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
