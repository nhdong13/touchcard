class AutomationsController < BaseController
  before_action :set_automation, only: [:edit, :update, :show, :destroy, :start_sending]
  before_action :set_aws_sign_endpoint, only: [:new, :edit]

  def index
    # Create default automation if there isn't one already

    @current_shop.post_sale_orders.create if @current_shop.card_orders.empty?
    # This flash works, but it's sort of annoying
    if @current_shop.current_subscription && @current_shop.current_subscription.quantity.to_i > 0 && CardOrder.num_enabled == 0
      flash.now[:notice] = "You are subscribed but not sending. Enable an automation to start sending."
    end

    @card_orders = @current_shop.card_orders.active
  end

  def show
  end

  # TODO: Re-enable automation creation
  #
  def new
    @automation = @current_shop.post_sale_orders.create
    respond_to do |format|
      flash[:notice] = "Automation successfully created"
      format.html { redirect_to action: 'index'}
      format.json { render json: @automation }
    end
    # NOTE: Don't think we actually need these now, since we're using json in card_orders instead
    # @automation.build_card_side_back(is_back: true)
    # @automation.build_card_side_front(is_back: false)
  end


  def edit
    @return_address =  @automation.return_address || ReturnAddress.new
    if @return_address.new_record?
      @current_shop.with_shopify_session do
        # This shop is retrieved directly from Shopify instead of from database in order to get address
        shop = ShopifyAPI::Shop.current
        @return_address.address_line1 = shop.address1
        @return_address.city = shop.city
        @return_address.state = shop.province
        @return_address.zip = shop.zip
        @return_address.country_code = shop.country_code
        @return_address.name = shop.name
      end
    end
  end

  # POST /automations
  # POST /automations.json
  def create
    @automation = @current_shop.post_sale_orders.create(automation_params)
    respond_to do |format|
      if @automation.save
        flash[:notice] = "Automation successfully created"
        format.html { redirect_to action: 'index'}
        format.json { render json: @automation }
      else
        flash.now[:error] = @automation.errors.full_messages.join("\n")
        format.html { render :new }
        format.json { render json: @automation.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /automations/1
  # PATCH/PUT /automations/1.json
  def update
    respond_to do |format|
      campaign_enabled_field_before_update = @automation.enabled
      if @automation.update(automation_params)
        if PauseUnpauseCampaignPolicy.enable_campaign? campaign_enabled_field_before_update, @automation.enabled
          if PauseUnpauseCampaignPolicy.passed_campaign? @automation
            @automation.update(enabled: false)
            flash[:error] = "Please edit the date for the campaign to run."
          else
            EnableDisableCampaignService.enable_campaign @automation, nil
            SendAllHistoryCardsJob.perform_later(@current_shop)
          end
        elsif PauseUnpauseCampaignPolicy.disable_campaign? campaign_enabled_field_before_update, @automation.enabled
          EnableDisableCampaignService.disable_campaign @automation, :paused , nil
        end
        flash[:notice] = "Automation successfully updated"
        format.html { redirect_to automations_path }
        format.json { render json: {
          message: "updated",
          campaign: ActiveModelSerializers::SerializableResource.new(@automation, {each_serializer: CardOrderSerializer}).to_json },
          status: :ok
        }
      else
        # flash[:error] = @automation.errors.full_messages.join("\n")
        format.html { render :edit }
        format.json { render json: @automation.errors.full_messages.join("\n"), status: :unprocessable_entity }
      end
    end
  end

  # TODO: Re-enable automation destruction
  #
  def destroy
    @automation.archive
    begin
      @automation.safe_destroy!
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { message: "Failed to delete" }, status: :internal_server_error }
      end
    end
    respond_to do |format|
      format.json { render json: { message: "Delete successfully" }, status: :ok }
    end
  end

  def start_sending
    @automation.update(enabled: true)
    send_postcard
    respond_to do |format|
      format.html { render plain: "OK" }
      format.json { render json: { message: "OK" }, status: :ok }
    end
  end

  private

  def send_postcard
    FetchHistoryOrdersJob.perform_now(@current_shop, @current_shop.post_sale_orders.last.send_delay, @automation)
  end

  def set_automation
    @automation = @current_shop.card_orders.find(params[:id])
  end

  def set_aws_sign_endpoint
    @aws_sign_endpoint = root_url + aws_sign_path
  end

  def automation_params
    params.require(:card_order).permit(
      :type,
      :enabled,
      :discount_exp,
      :discount_pct,
      :international,
      :send_delay,
      :budget_type,
      :budget,
      :budget_update,
      :campaign_type,
      :send_date_start,
      :send_date_end,
      :limit_cards_per_day,
      :campaign_name,
      :send_continuously,
      filters_attributes: [[:id, :_destroy, filter_data: {}]],
      front_json: [:version, :background_url, :discount_x, :discount_y],
      back_json: [:version, :background_url, :discount_x, :discount_y],
      return_address_attributes: [:id, :name, :address_line1, :address_line2, :city, :state, :zip, :country_code]
    )
  end
end
