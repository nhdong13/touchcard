require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe ".marketing_eligible" do
    it "returns only customers that are opt in for marketing" do
      marketing_customer = create(:customer, accepts_marketing: true, shopify_id: 1)
      non_marketing_customer = create(:customer, shopify_id: 2)

      result = Customer.marketing_eligible

      expect(result.size).to eq 1
      expect(result.first.first_name).to eq marketing_customer.first_name
    end
  end

end
