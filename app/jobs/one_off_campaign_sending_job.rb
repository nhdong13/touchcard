class OneOffCampaignSendingJob < ActiveJob::Base
  queue_as :default

  def perform campaign_id
    campaign = CardOrder.find(campaign_id)
    shop = campaign.shop
    removed_duplicate_orders_of_customer(shop.orders).each do |order|
      campaign.prepare_for_sending(order)
    end

    if campaign.imported_customers_url.present?
      ImportedCustomer.import_csv(campaign.imported_customers_url, campaign_id) unless campaign.imported_customers.present?
      campaign.imported_customers.find_each do |cus|
        return if campaign.out_of_credit?
        
        next if cus.international? || cus.postcard.present?

        postcard = cus.build_postcard(
          card_order: campaign,
          send_date: Date.current,
          paid: false
        )
        
        if campaign.can_pay?(postcard)
          postcard.paid = true
          postcard.save
        else
          return postcard.errors.full_messages.map{|msg| msg}.join("\n")
        end
      end
    end

    campaign.complete!
  end

  private

  def removed_duplicate_orders_of_customer orders
    res = []
    orders.each do |order|
      res.push(order) if res.none?{|el| el.customer_id == order.customer_id}
    end
    res
  end

end
