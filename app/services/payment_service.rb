class PaymentService
  class << self
  	def pay_postcard_for_campaign_monthly shop, card_order, postcard
  		return true if postcard.paid

  		if shop.credit < postcard.cost
        card_order.previous_campaign_status = CardOrder.campaign_statuses[card_order.campaign_status]
  			card_order.out_of_credit!
  			card_order.save!
  			return false
  		end

  		if card_order.monthly?
  			available_budget = card_order.budget - card_order.budget_used
  			if available_budget < postcard.cost
          card_order.previous_campaign_status = CardOrder.campaign_statuses[card_order.campaign_status]
  				card_order.paused!
  				card_order.save!
  				return false
  			end
  			card_order.budget_used += postcard.cost
  			card_order.save!
  		end
  		shop.credit -= postcard.cost
      postcard.paid = true
      postcard.save!
  		shop.save!
  		return true
  	end

  	def pay_for_campaign_one_off shop, card_order

  	end

    def refund_cards_when_cancelled shop, card_order
      paid_postcards = Postcard.where(card_order_id: card_order.id, paid: true, sent: false)
      paid_postcards.find_each do |postcard|
        shop.credit += postcard.cost
        postcard.paid = false
        postcard.save!
      end
      shop.save!
    end
  end
end