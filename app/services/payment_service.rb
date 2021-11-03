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
      shop_credit = shop.credit
      result = true
      card_order.postcards.find_each do |postcard|
        next if postcard.paid
        shop_credit -= postcard.cost
        if shop_credit < 0.89
          result = false
          EnableDisableCampaignService.disable_campaign campaign, :out_of_credit, "#{campaign.campaign_name} is out of credit"
          break
        end
      end

      if result
        shop.credit = shop_credit
        shop.save
        card_order.postcards.update_all "paid = TRUE"
      end

      result
  	end

    def refund_cards_when_cancelled shop, card_order
      ActiveRecord::Base.transaction do
        paid_postcards = Postcard.where(card_order_id: card_order.id, paid: true, sent: false)
        total_refund = 0
        paid_postcards.find_each do |postcard|
          postcard.paid = false
          postcard.canceled = true
          total_refund += postcard.cost if postcard.save
        end
        shop.credit += total_refund
        shop.save!
      end
    end
  end
end