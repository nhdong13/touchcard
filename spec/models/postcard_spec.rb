require 'rails_helper'

RSpec.describe Postcard, type: :model do

  describe "#send_card" do
    let(:customer) { postcard.customer }
    let!(:address) { create(:address, customer: customer) }
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }


    background1_path = (Rails.root + 'spec/images/background_1.jpg').to_s
    background2_path = (Rails.root + 'spec/images/background_2.jpg').to_s
    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s

    json_with_coupon = {
        "version":0,
        "background_url":background1_path,
        "discount_x":376,
        "discount_y":56
    }

    json_no_coupon = {
        "version":0,
        "background_url": background2_path,
        "discount_x": nil,
        "discount_y": nil
    }

    let(:card_order) { create(:card_order,
                              discount_pct: -37,
                              discount_exp: 2,
                              front_json: json_with_coupon,
                              back_json: json_no_coupon
                              ) }
    let(:shop) { card_order.shop }

    before do
      Timecop.freeze(Time.local(1990))
    end

    after do
      Timecop.return
    end

    # TODO: Move these tests into LobRenderUtil...
    it "renders_front_with_coupon" do
      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = 37
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: true)
      expected_png_path = (Rails.root + 'spec/images/expected_front_coupon@2x.png').to_s
      puts "Comparing: \n#{output_path} \nwith: \n#{expected_png_path} "
      expect(FileUtils.compare_file(output_path, expected_png_path)).to be_truthy  # Compare with expected output
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "renders_back_no_coupon" do
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: false)
      expected_png_path = (Rails.root + 'spec/images/expected_back_no_coupon@2x.png').to_s
      expect(FileUtils.compare_file(output_path, expected_png_path)).to be_truthy  # Compare with expected output
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    it "raises_error_on_missing_data" do
      postcard.discount_exp_at = Time.now + 23.days
      # Do NOT set discount code or percentage: should throw error
      # postcard.discount_code = "XXX-YYY-ZZZ"
      # postcard.discount_pct = 37
      expect{ LobRenderUtil.render_side_png(postcard: postcard, is_front: true) }.to raise_error(LobApiController::MissingPostcardDataError)
    end

    it "prepares_card" do
      price_rule_id = stub_shopify(:price_rules, :create)[:price_rule][:id]
      stub_shopify(:discounts, :create, entity_uri: "price_rules/#{price_rule_id}/discount_codes")
      postcard.prepare_card
      expect(postcard.discount_code).to eq "XXX-YYY-ZZZ"
      expect(postcard.price_rule_id).to eq 3561328458
    end

    it "bad_discount_code_throws_error" do
      price_rule_id = stub_shopify(:price_rules, :create)[:price_rule][:id]
      stub_shopify(:discounts, :create, entity_uri: "price_rules/#{price_rule_id}/discount_codes", overrides: {discount_code: { code: "not the expected format" }})
      expect{ postcard.prepare_card }.to raise_error(Postcard::DiscountCreationError)
    end

    it "sends_card" do
      price_rule_id = stub_shopify(:price_rules, :create)[:price_rule][:id]
      stub_shopify(:discounts, :create, entity_uri: "price_rules/#{price_rule_id}/discount_codes")
      stub_request(:post, "https://api.lob.com/v1/postcards")
        .to_return(body: File.read("#{Rails.root}/spec/fixtures/lob/postcards/create/default.json"))
          .with(basic_auth: ["#{ENV['LOB_API_KEY']}", ""])
      postcard.send_card
      expect(postcard.sent).to eq true
      expect(postcard.date_sent).to eq Date.today
      # XXX: because comparison is to noon small probability of failure if run exactly at midnight
      expect(postcard.estimated_arrival.noon).to eq 6.business_days.from_now.noon
      expect(postcard.postcard_id).to eq "psc_14c1b66f31264c34"
    end
  end

  describe ".ready_for_arrival_notification" do
    it "returns list of postcards where arrival_notification_sent is false" do
      postcard = create(:postcard, estimated_arrival: 4.days.ago)
      sent_postcard = create(:postcard,
                             card_order: postcard.card_order,
                             customer: postcard.customer,
                             arrival_notification_sent: true)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 1
    end

    it "returns list of postcards which arrived more than 3 days ago" do
      postcard = create(:postcard, estimated_arrival: 4.days.ago)
      postcard_not_arrived = create(:postcard,
                             card_order: postcard.card_order,
                             customer: postcard.customer,
                             arrival_notification_sent: false,
                             estimated_arrival: 2.days.ago)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 1
    end

    it "doesn't return postcards which have not arrived" do
      postcard = create(:postcard, estimated_arrival: 1.days.from_now)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 0
    end
  end
end
