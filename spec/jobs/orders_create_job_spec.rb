# require 'rails_helper'

# RSpec.describe OrdersCreateJob, type: :job do
#   include ActiveJob::TestHelper

#   def stub_order(key, overrides={})
#     order_text = File.read(
#       "#{Rails.root}/spec/fixtures/shopify/orders/show/#{key}.json")
#     order_obj = JSON.parse(order_text).with_indifferent_access
#     order_obj.merge!(overrides)
#     #stub_request(:get, "https://#{shop.domain}/admin/orders/#{order_obj[:order][:id]}.json")
#     # .to_return(body: order_obj[:order].to_json)
#     api_version = ShopifyAPI::ApiVersion.find_version(ShopifyApp.configuration.api_version)
#     order_path = api_version.construct_api_path("orders/#{order_obj[:order][:id]}.json")
#     stub_request(:get, "https://#{shop.domain}#{order_path}")
#         .to_return(body: order_obj[:order].to_json)
#     order_obj[:order]
#   end

#   let!(:shop) { create(:shop, credit: 2) }
#   let!(:card_order) { create(:card_order, shop: shop) }
#   let(:order) { create(:order) }
#   subject(:job) do
#     webhook_text = File.read("#{Rails.root}/spec/fixtures/shopify/webhooks/orders_create.json")
#     webhook_obj = JSON.parse(webhook_text).with_indifferent_access
#     described_class.perform_later(shop_domain: shop.domain, webhook: webhook_obj)
#   end

#   it 'queues the job' do
#     expect { job }
#       .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
#   end

#   it 'is in default queue' do
#     expect(OrdersCreateJob.new.queue_name).to eq('default')
#   end

#   describe "#perform" do
#     context "order already exists" do
#       it "ignores" do
#         stub_order("no_customer")
#         perform_enqueued_jobs { job }
#         expect(Customer.count).to eq 0
#         expect(Postcard.count).to eq 0
#         expect(Order.count).to eq 1
#       end
#     end

#     context "order has customer" do
#       context "without default address" do
#         it "saves order but not postcard" do
#           stub_order("no_default_address")
#           perform_enqueued_jobs { job }
#           expect(Customer.count).to eq 1
#           expect(Address.count).to eq 0
#           expect(Postcard.count).to eq 0
#           expect(Order.count).to eq 1
#         end
#       end

#       context "who is new" do
#         context "valid card order" do
#           it "creates postcard" do
#             stub_order("everything")
#             perform_enqueued_jobs { job }

#             expect(Postcard.count).to eq 1
#           end

#           it "deducts shop credits" do
#             stub_order("everything")
#             perform_enqueued_jobs { job }

#             expect(Shop.find(shop.id).credit).to eq shop.credit - 1
#           end

#           it "ignores duplicate order creation" do
#             stub_order("everything")
#             perform_enqueued_jobs { job }
#             expect(Postcard.count).to eq 1
#             expect(Order.count).to eq 1

#             webhook_text = File.read("#{Rails.root}/spec/fixtures/shopify/webhooks/orders_create.json")
#             webhook_obj = JSON.parse(webhook_text).with_indifferent_access
#             OrdersCreateJob.perform_now(shop_domain: shop.domain, webhook: webhook_obj)
#             expect(Postcard.count).to eq 1
#             expect(Order.count).to eq 1

#           end
#         end

#         context "no street in address" do
#           it "saves order but doesn't create postcard" do
#             stub_order("no_street_in_address")
#             perform_enqueued_jobs { job }
#             expect(Customer.count).to eq 1
#             expect(Address.count).to eq 1
#             expect(Postcard.count).to eq 0
#             expect(Order.count).to eq 1
#           end
#         end

#         context "shop not enough credits" do
#           before(:each) { shop.update(credit: 0) }

#           it "doesn't create postcard" do
#             stub_order("everything")
#             perform_enqueued_jobs { job }
#             expect(Postcard.count).to eq 0
#           end

#           it "doesn't deducts shop credits" do
#             stub_order("everything")
#             perform_enqueued_jobs { job }

#             expect(Shop.find(shop.id).credit).to eq shop.credit
#           end
#         end

#         it "creates customer" do
#           stub_order("everything")
#           perform_enqueued_jobs { job }

#           expect(Customer.count).to eq 1
#         end

#         it "creates customer address" do
#           stub_order("everything")
#           perform_enqueued_jobs { job }

#           expect(Address.count).to eq 1
#         end
#       end

#       context "who is not new" do
#         # Technically `s_order` "with_discount" isn't the same JSON as the `job` above "/spec/fixtures/shopify/webhooks/orders_create.json"
#         # but the source is the same, so we can treat them as identical for testing purposes
#         let!(:s_order) { stub_order("with_discount") }  # Make sure that we've stubbed the HTTP call for `job` webhook

#         context "and discount code exists on postcard"  do

#           # We already have a card_order and postcard from above
#           # here we create a second set, so we can test multiple card_orders
#           let!(:redemption_card_order) { create(:card_order, shop: shop) }
#           let!(:redemption_postcard) { create(:postcard, discount_code: 'TENOFF', card_order: redemption_card_order) }

#           it "connects order to postcard" do
#             perform_enqueued_jobs { job }

#             # This job should create a new order
#             redemption_order = Order.last

#             # It should also link this order's postcard_id to the `redemption_postcard` above because 'TENOFF' matches the discount
#             expect(redemption_order.postcard.id).to eq(redemption_postcard.id)

#             # The card_order factory from above isn't involved here, so it shouldn't have revenue
#             expect(card_order.revenue).to eq 0

#             # The redemption_card_order should have the proper revenue from the newly placed order
#             expect(redemption_card_order.revenue).to eq 40994

#             # The shop should also reflect is
#             expect(redemption_order.shop.revenue).to eq 40994

#             # This should add 8800 to shop.revenue and original factory card_order, but leave the redemption_card_order unaffected
#             another_redemption_order = create(:order, shop: shop, postcard_id: Postcard.last.id, total_price: 8800)
#             expect(card_order.revenue).to eq 8800
#             expect(redemption_card_order.revenue).to eq 40994
#             expect(shop.revenue).to eq 49794

#           end
#         end

#         context "and exists in db" do
#           let!(:customer) do
#             create(:customer, shopify_id: s_order[:customer][:id])
#           end

#           it "updates the customer data" do
#             perform_enqueued_jobs { job }
#             expected = s_order[:customer].slice(:email, :first_name, :last_name)
#             expect(Customer.first.attributes).to include(expected)
#           end
#         end

#         context "and has been sent a postcard" do
#           let!(:customer) do
#             create(:customer, shopify_id: s_order[:customer][:id])
#           end
#           let!(:postcard) { create(:postcard, discount_code: 'TENOFF',
#                                     postcard_trigger: order, customer: customer) }
#           before(:each) { order.update!(customer: customer) }
#           it "does not register the triggered postcard as revenue postcard" do
#             # Note: This test is a refactored broken test. It's not hugely enlightening as-is.
#             perform_enqueued_jobs { job }
#             new_order = Order.find_by(shopify_id: s_order[:id])
#             expect(new_order.postcard.id).to eq(postcard.id)
#             expect(new_order.shop.revenue).to eq 0
#             expect(new_order.shop.card_orders.last.revenue).to eq 0
#           end
#         end
#       end
#     end # /has customer
#   end
# end
