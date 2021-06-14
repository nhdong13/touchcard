class PaymentService
	def self.pay shop, card_order, postcard
		return false if postcard.paid?
		
		if shop.credit < postcard.cost 
			card_order.campaign_status = CardOrder.out_of_credit
			card_order.save!
			return false
		end

		available_budget = card_order.budget - card_order.budget_used
		if available_budget < postcard.cost 
			card_order.campaign_status = CardOrder.paused
			card_order.save!
			return false
		end

		shop.credit -= postcard.cost
		card_order.budget_used += postcard.cost
		card_order.save!
		shop.save!
		return true
	end
end