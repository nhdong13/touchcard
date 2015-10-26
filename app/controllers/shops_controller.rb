class ShopsController < AuthenticatedController

  def show
    @shop = Shop.find(params[:id])
  end

  def edit
    @shop = Shop.find(params[:id])
    @shop.new_sess
    @last_month = ShopifyAPI::Customer.where(:created_at_min => (Time.now - 1.month)).count
    @current = @shop.charge_amount || 0
  end

  def update
    @shop = Shop.find(params[:id])
    @shop.assign_attributes(shop_params)

    # Save which attributes are updated
    changed =  @shop.changed_attributes
    @shop.save!

    # Check if a billing attribute has been changed or not
    unless changed[:charge_amount] == nil
      charge_url = @shop.new_charge(shop_params[:charge_amount])
      render :text => "<html><body><script type='text/javascript' charset='utf-8'>parent.location.href = '#{charge_url}';</script></body></html>"
    else
      flash[:success] = "Shop setting updated"
      redirect_to root_url
    end
  end

  private

  def shop_params
    params.require(:shop).permit(
      :customer_pct,
      :charge_amount)
  end

end
