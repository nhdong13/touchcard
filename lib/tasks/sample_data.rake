require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :sample_data => :environment do
    puts "Populating Database..."

    shop = Shop.where(domain:"SAMPLE_DATA").last || Shop.create!(
      domain: "SAMPLE_DATA",
      token: "SAMPLE_DATA",
      email: "dustin+sample_data@touchcard.co"

    )
    raise 'To add Sample Data please create a Shop record by logging in via Shopify with at least one shop' if shop == nil
    if Rails.env.production? && shop.email.split('@').last != "touchcard.co"
      raise 'WARNING: In production mode shops require @touchcard.co owner email'
    end

    create_card_order_and_sides shop if shop.card_orders.count == 0
    populate_data shop if shop.orders.count == 0
  end

  def create_card_order_and_sides (shop)
    shop.card_orders.create!(
      type: 'PostSaleOrder',
      discount_pct: rand(10..30),
      enabled: true,
      international: false,
      send_delay: 1,
    )
  end


  def populate_data (shop)
    num_entries = 50

    num_entries.times do |n|

      non_us = rand < 0.2
      shopify_order_id = rand(1_000_000_000..9_999_999_999)

      c = Customer.create!(
        shopify_id: rand(1_000_000_000..9_999_999_999),
        email: "sample_#{Customer.count+1}@touchcard.co",
        verified_email: true,
        total_spent: rand(1..10_000_00),
        orders_count: 1,
        accepts_marketing: rand < 0.5,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        tax_exempt: rand < 0.1,
        last_order_id: shopify_order_id,
      )

      address = c.addresses.create!(
        shopify_id: rand(1_000_000_000..9_999_999_999),
        address1: Faker::Address.street_address,
        address2: rand < 0.3 ? Faker::Address.secondary_address : nil,
        company: Faker::Company.name,
        country: non_us ? Faker::Address.country : 'United States',
        country_code: non_us ? Faker::Address.country_code : 'US',
        city: Faker::Address.city,
        province: Faker::Address.state,
        province_code: Faker::Address.state_abbr,
        zip: Faker::Address.zip_code,
        first_name: c.first_name,
        last_name: c.last_name,
        name: "#{c.first_name} #{c.last_name}".chomp(" "),
        default: true,
      )

      price = rand(1..1_000_00)
      order = c.orders.create!(
        shopify_id: shopify_order_id,
        shop: shop,
        processed_at: Time.now,
        financial_status: "paid",
        total_discounts: 0,
        total_line_items_price: price,
        total_price: price,
        total_tax: 0,
        discount_codes: "--- []"
      )

      discount_chars = ("A".."Z").to_a.sample(9).join
      discount_code = "#{discount_chars[0...3]}-#{discount_chars[3...6]}-#{discount_chars[6...9]}"

      # case n % 3
      #   when 1
      #   when 2
      #   else
      # end
      # send_date =
      # date_sent =

      start_date = Time.now - 10.weeks
      end_date = Time.now + 2.weeks

      send_date = start_date + ((end_date - start_date) * n/num_entries)
      sent = send_date < Time.now
      date_sent = sent ?  send_date : nil

      postcard = c.postcards.create!(
        card_order_id: shop.card_orders.last.id,
        discount_code: discount_code,
        send_date: send_date,
        date_sent: date_sent,
        sent: sent,
        postcard_id: sent ? "psc_xyz" : nil,
        postcard_trigger_id: order.id,
        postcard_trigger_type: 'Order',
        paid: true,
        estimated_arrival: Time.now + 2.weeks,
        arrival_notification_sent: false,
        expiration_notification_sent: false,
        discount_pct: shop.card_orders.last.discount_pct,
        canceled: false,
      )
    end

    # # Mark some as redeemed
    # # NOT YET WORKING
    # Postcard.where(sent: true).each do |p|
    #   next if rand > 0.3
    #   next unless p.sent
    #   price = rand(1..1_000_00)
    #   p.orders.create!(
    #     shopify_id: rand(1_000_000_000..9_999_999_999),
    #     shop: shop,
    #     processed_at: Time.now,
    #     financial_status: "paid",
    #     total_discounts: 0,
    #     total_line_items_price: price,
    #     total_price: price,
    #     total_tax: 0,
    #     discount_codes: "--- []",
    #     customer_id: p.customer.id
    #   )
    #
    # end

  end

  # def load_record(key, overrides={})
  #   order_text = File.read("#{Rails.root}/lib/assets/tasks/sample_data/#{key}.json")
  #   order_obj = JSON.parse(order_text).with_indifferent_access
  #   order_obj.merge!(overrides)
  #   order_obj
  # end

end
