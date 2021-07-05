class PaymentService
	def self.pay_postcard_for_campaign_monthly shop, card_order, postcard
		return false if postcard.paid?
		
		if shop.credit < postcard.cost 
			card_order.out_of_credit!
			card_order.save!
			return false
		end

		if card_order.monthly?
			available_budget = card_order.budget - card_order.budget_used
			if available_budget < postcard.cost 
				card_order.paused!
				card_order.save!
				return false
			end
			card_order.budget_used += postcard.cost
			card_order.save!
		end

		shop.credit -= postcard.cost
		shop.save!
		return true
	end

	def self.pay_for_campaign_one_off shop, card_order

	end
end