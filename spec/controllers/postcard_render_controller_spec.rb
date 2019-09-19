require "rails_helper"

RSpec.describe PostcardRenderController, type: :controller do

  let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order, discount_code: 'sam-ple-xxx', discount_pct: 33) }
  let(:card_order) { create(:card_order) }

  describe "#render_side" do
    it "raises error when discount code is expected but missing on postcard" do
      card_order.discount_pct = 33
      card_order.discount_exp = 12
      postcard.discount_code = nil
      expect {
        PostcardRenderController.render_side(postcard: postcard, is_front: true)
      }.to raise_error(PostcardRenderController::MissingPostcardDataError)
    end

    it "does not raise error when card order discount data is empty" do
      card_order.discount_pct = nil
      postcard.discount_code = nil
      expect {
        PostcardRenderController.render_side(postcard: postcard, is_front: true)
      }.not_to raise_error
    end
  end
end
