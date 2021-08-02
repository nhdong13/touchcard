=begin
  This class is used to handle a shop's credit in sending postcard process and change card order status if necessary
  This should be distinguish between this class and any modules that deal with Stripe
=end
class PaymentService
  class << self
  	def pay_postcard_for_campaign_monthly shop, card_order, postcard
  		return true if postcard.paid

  		if shop.credit < postcard.cost
        EnableDisableCampaignService.disable_campaign campaign, :out_of_credit, "#{campaign.campaign_name} is out of credit"
  			return false
  		end

  		if card_order.monthly?
  			available_budget = card_order.budget - card_order.budget_used
  			if available_budget < postcard.cost
          EnableDisableCampaignService.disable_campaign campaign, :paused, "#{campaign.campaign_name} is exceeded current budget"
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