class ShopsController < BaseController
  before_action :set_shop


  def edit
  end

  # def update
  #   if @shop.update(permitted_params)
  #     flash[:notice] = "Settings successfully updated"
  #   else
  #     flash[:error] = @automation.errors.full_messages.join("\n")
  #   end
  #   render :edit
  # end

  private

  def set_shop
    @shop = @current_shop
  end

  # def permitted_params
  # end

end
