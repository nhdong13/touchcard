class ChargeController < AuthenticatedController

  def activate
    require 'slack_notify'

    #retrieve the shop and start new session with Shopify
    shop = Shop.find_by(:charge_id => params[:charge_id])
    shop.new_sess

    #Find the charge on Shopify's end, and check that it is accepted
    shopify_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
    if shopify_charge.status == "accepted"
      begin
        shopify_charge.activate
        shop.charge_date = Date.today
        shop.charge_amount = shopify_charge.price
        shop.save!
      rescue
        #SlackNotify.error(shop.domain, error) #Send error to slack if charge isn't activated
        #TODO Add error display
        redirect_to root_url
      end

    #Handle duplicate charge accepted callback from Shopify
    elsif shopify_charge.status == "active"
      puts "duplicate charge callback"
      redirect_to root_url

    #Handle a declined charge activation
    else
      if ENV['RAILS_ENV'] == "development"
        puts shopify_charge.status
      end
      flash[:error] = "Not activated"
      redirect_to root_path
    end
  end

end
