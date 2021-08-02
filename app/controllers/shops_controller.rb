class ShopsController < BaseController
  before_action :set_shop


  # PATCH/PUT /settings/set_campaign_filter_option
  def set_campaign_filter_option
    filter = campaign_filter_params
    if @shop.update(campaign_filter_option: filter)
      render :json => {:message => "Update campagin filter successfully", :filter => campaign_filter_params}, status: :ok
    else
      render :json => {:message => @shop.errors.full_messages.join("\n")}, status: :unprocessable_entity
    end
  end

  # GET /settings/set_campaign_filter_option.json
  def get_campaign_filter_option
    respond_to do |format|
      format.html
      format.json {
        render :json => {:filter => @shop.campaign_filter_option}, status: :ok
      }
    end
  end

  # GET /settings/get_credit.json
  def get_credit
    respond_to do |format|
      format.html
      format.json {
        render :json => {:credit => @shop.credit}, status: :ok
      }
    end
  end

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

  private
    def campaign_filter_params
      params.require(:filters).permit(:type, {:status => [] }, {:dateCreated => {}})
    end

end
