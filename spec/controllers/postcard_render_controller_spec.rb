require "rails_helper"

RSpec.describe PostcardRenderController, type: :feature do  # with :controller here instead of :feature rendering would return empty strings

  let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order, discount_pct: -33, discount_code: 'TEST-ING-YO', discount_exp_at: Time.utc(2020) + 2.weeks ) }
  let(:card_order) { create(:card_order) }

  describe "#render_side" do

    before do
      FileUtils.mkdir_p "#{Rails.root}/tmp/test/"
    end

    it "generates html with discount coupon when discount_code, discount_pct, and coupon placement are there" do
      card_side_div = %(<div id="postcard-render-card-side" data-attributes="{&quot;version&quot;:0,&quot;background_url&quot;:&quot;#{(Rails.root + 'spec/images/background_1.jpg').to_s}&quot;,&quot;discount_x&quot;:376,&quot;discount_y&quot;:56}" data-discount-pct="33" data-discount-exp="01/15/2020" data-discount-code="TEST-ING-YO"></div>)
      expected_html = PostcardRenderSpecHelper.postcard_html(card_side_div: card_side_div)
      rendered_html = PostcardRenderController.render_side(postcard: postcard, is_front: true)
      tmp_path = "#{Rails.root}/tmp/test/render_test_complete_coupon.html"
      File.open(tmp_path, 'w') {|f| f.write(rendered_html) }
      puts tmp_path
      expect(rendered_html).to eq expected_html
    end

    it "generates html without coupon when discount_pct missing" do
      card_order.discount_pct = nil
      card_side_div = %(<div id="postcard-render-card-side" data-attributes="{&quot;version&quot;:0,&quot;background_url&quot;:&quot;#{(Rails.root + 'spec/images/background_1.jpg').to_s}&quot;,&quot;discount_x&quot;:376,&quot;discount_y&quot;:56}" data-discount-code="TEST-ING-YO"></div>)
      expected_html = PostcardRenderSpecHelper.postcard_html(card_side_div: card_side_div)
      rendered_html = PostcardRenderController.render_side(postcard: postcard, is_front: true)
      tmp_path = "#{Rails.root}/tmp/test/render_test_discount_code_missing.html"
      File.open(tmp_path, 'w') {|f| f.write(rendered_html) }
      puts tmp_path
      expect(rendered_html).to eq expected_html
    end

    it "generates html without discount coupon when discount_exp missing" do
      postcard.discount_exp_at = nil
      card_side_div = %(<div id="postcard-render-card-side" data-attributes="{&quot;version&quot;:0,&quot;background_url&quot;:&quot;#{(Rails.root + 'spec/images/background_1.jpg').to_s}&quot;,&quot;discount_x&quot;:376,&quot;discount_y&quot;:56}" data-discount-pct="33" data-discount-code="TEST-ING-YO"></div>)
      expected_html = PostcardRenderSpecHelper.postcard_html(card_side_div: card_side_div)
      rendered_html = PostcardRenderController.render_side(postcard: postcard, is_front: true)
      tmp_path = "#{Rails.root}/tmp/test/render_test_discount_exp_missing.html"
      File.open(tmp_path, 'w') {|f| f.write(rendered_html) }
      puts tmp_path
      expect(rendered_html).to eq expected_html
    end
  end
end
