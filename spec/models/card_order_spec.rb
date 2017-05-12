require "rails_helper"

RSpec.describe CardOrder, type: :model do

  describe "#send_postcard?" do
    it "returns false if total amount is insufficient regardless of line items price" do
      filter = create(:filter)
      filter.filter_data["minimum"] = 50

      card_order = setup_card_order
      card_order.filters = [filter]

      order = create(:order)
      order.total_line_items_price = 6000 # $60.00
      order.total_price = 1050 # $10.50

      expect(card_order.send_postcard?(order)).to eq false
    end

    it "returns true if total_price is high enough" do
      filter = create(:filter)
      filter.filter_data["minimum"] = 50

      card_order = setup_card_order
      card_order.filters = [filter]
      order = create(:order)

      order.total_line_items_price = 6000 # $60.00
      order.total_price = 5001 # $50.01

      expect(card_order.send_postcard?(order)).to eq true
    end

    it "returns false when the order cost does not exceed the filter cost" do
      filter = create(:filter)
      filter.filter_data["minimum"] = 10.00
      card_order = setup_card_order
      card_order.filters = [filter]
      order = create(:order)
      order.total_price = 1000 # $10.00

      expect(card_order.send_postcard?(order)).to eq false
    end

    it "returns true for no cost order when there is no filter" do
      card_order = setup_card_order
      order = create(:order)
      order.total_price = 0

      expect(card_order.send_postcard?(order)).to eq true
    end

  end

  describe "#cards_sent" do
    it "count number of postcards sent for current shop subscription" do
      card_order = setup_card_order
      ned = create(:customer, shopify_id: "1", first_name: 'Ned',
                   last_name: "Stark")
      create(:postcard, customer: ned, card_order: card_order)
      create(:postcard, customer: ned, card_order: card_order)
      # Old card, not in current sub period
      create(:postcard, customer: ned, card_order: card_order, created_at: 60.days.ago)
      expect(card_order.cards_sent).to eq 2
    end

    it "only count cards from current subscription" do
      card_order = setup_card_order
      ned = create(:customer, shopify_id: "1", first_name: 'Ned',
                   last_name: "Stark")

      create(:postcard, customer: ned, card_order: card_order, sent: true,
             created_at: 3.days.ago)
      create(:postcard, customer: ned, card_order: card_order, sent: true,
             created_at: 50.days.ago)

      expect(card_order.cards_sent).to eq 1
    end

    it "returns 0 if no postcards are sent" do
      card_order = setup_card_order

      expect(card_order.cards_sent).to eq 0
    end
  end

  describe "#cards_sent_total" do
    it "count total number of postcards sent for shop" do
      card_order = setup_card_order
      ned = create(:customer, shopify_id: "1", first_name: 'Ned',
                   last_name: "Stark")

      current_sub_postcard = create(:postcard, customer: ned,
                                    card_order: card_order, sent: true,
                                    created_at: 3.days.ago)
      old_sub_postcard = create(:postcard, customer: ned,
                                card_order: card_order, sent: true,
                                created_at: 50.days.ago)

      expect(card_order.cards_sent_total).to eq 2
    end

    it "returns 0 if no postcards are sent" do
      card_order = setup_card_order

      expect(card_order.cards_sent_total).to eq 0
    end
  end
end

def setup_card_order
  shop = create(:shop)
  create(:subscription, shop: shop,
          current_period_start: 25.days.ago,
          current_period_end: 5.days.from_now,
          stripe_id: "test")
  create(:card_order, shop: shop)
end
