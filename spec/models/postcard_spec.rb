require 'rails_helper'

RSpec.describe Postcard, type: :model do

  describe "#send_card" do
    let(:customer) { postcard.customer }
    let!(:address) { create(:address, customer: customer) }
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }


    # back_json = '{"version":0,"background_url":"https://touchcard-data-dev.s3.amazonaws.com/uploads/90a2ff06-16b0-4fee-98cb-37965ccf59a0/_card1C_back_new.png","discount_x":238,"discount_y":17}'

    LobRenderUtil.lob_css_pack_path

    background1_path = (Rails.root + 'spec/images/background_1.jpg').to_s
    background2_path = (Rails.root + 'spec/images/background_2.jpg').to_s

    bad_png_path = (Rails.root + 'spec/images/bad_output_retina.png').to_s


    let(:card_order) { create(:card_order,
                              discount_pct: -37,
                              discount_exp: 2,
                              front_json: '{"version":0,"background_url":"' + background1_path + '","discount_x":376,"discount_y":56}',
                              back_json: '{"version":0,"background_url":"' + background2_path + '","discount_x":null,"discount_y":null}'
                              ) }
    let(:shop) { card_order.shop }

    before do
      Timecop.freeze(Time.local(1990))
    end

    after do
      Timecop.return
    end

    it "renders_front_with_coupon" do
      postcard.discount_exp_at = Time.now + 23.days
      postcard.discount_code = "XXX-YYY-ZZZ"
      postcard.discount_pct = 37
      output_path = postcard.render_side_png(card_order.front_json)
      expected_png_path = (Rails.root + 'spec/images/expected_front_coupon@2x.png').to_s
      expect(FileUtils.compare_file(output_path, expected_png_path)).to be_truthy  # Compare with expected output
      expect(FileUtils.compare_file(output_path, bad_png_path)).to be_falsey  # Compare with bad output (confirms test)
    end

    # TODO: Enable no coupon test

    # it "renders_front_without_coupon" do
    #   output_path = postcard.render_side_png(card_order.front_json)
    #   byebug
    # end


    # TODO: Enable back render test
    #
    # it "renders_back" do
    #   back_png_path = postcard.render_side_png(card_order.back_json)
    #   expected_png_path = (Rails.root + 'spec/images/expected_output_back_retina.png').to_s
    #   byebug
    #   expect(FileUtils.compare_file(back_png_path, expected_png_path)).to be_truthy   # Compare with expected output
    #   expect(FileUtils.compare_file(back_png_path, bad_png_path)).to be_falsey   # Compare with bad output (confirms test)
    # end


    it "works" do
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
