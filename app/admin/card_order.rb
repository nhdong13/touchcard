require "card_util"

ActiveAdmin.register CardOrder do
  menu priority: 5, label: "Campaigns"
  actions :index, :show

  breadcrumb do [
    link_to('Admin', admin_root_path),
   link_to('Campaigns', admin_card_orders_path)
  ]
  end
  member_action :change_sending_status, method: :get do
    @card_order = CardOrder.find(params[:id])
  end

  member_action :change_enabled, method: :put do
    card_order = CardOrder.find(params[:id])
    enabled = params[:card_order][:enabled]
    card_order.enabled = enabled
    card_order.save!
    redirect_to admin_card_order_path(card_order)
  end

  member_action :send_sample, method: [:get, :post] do
    if request.get?
      @card_order = CardOrder.find(params[:id])
      @shop = @card_order.shop
    elsif request.post?
      card_order = CardOrder.find(params[:id])
      permitted_params = params[:lob_sample_address].permit(:name,
                                                            :address_line1,
                                                            :address_city,
                                                            :address_state,
                                                            :address_zip,
                                                            :address_country)
      lob_sample_address = permitted_params.to_hash
      begin
        lob_response = CardUtil.send_promo_card(card_order, lob_sample_address)
        puts lob_response
        recipient = lob_response['to']['name']
        lob_admin_path = "https://dashboard.lob.com/#/postcards/#{lob_response['id']}"
        SlackNotify.message("#{current_admin_user.email} sent #{card_order.shop.domain} sample " \
                            "to #{recipient}. #{lob_admin_path} ", true)
        redirect_to show_sample_admin_card_order_path({card_order_id: card_order.id, lob_response: lob_response})
      rescue Lob::InvalidRequestError => error
        render json: error.to_s, status: 422, root: false
      end
    end
  end

  member_action :show_sample, method: :get do
    @card_order = CardOrder.find(params[:card_order_id])
    @lob_id = params.dig(:lob_response, :id)
    @lob_url = params.dig(:lob_response, :url)
    @lob_admin_path = "https://dashboard.lob.com/#/postcards/#{params[:lob_response][:id]}"
  end


  filter :shop , as: :select, collection: ->{Shop.select(:domain, :id).order(:domain)}
  filter :discount_pct
  filter :discount_exp
  filter :enabled
  filter :international
  filter :created_at
  filter :updated_at

  index title: "Campaigns" do
    # actions
    column :id do |card_order|
      link_to card_order.id, admin_card_order_path(card_order)
    end

    column :campaign_name do |card_order|
      link_to card_order.campaign_name, admin_card_order_path(card_order)
    end
    column :campaign_type do |card_order|
      card_order.campaign_type&.gsub("_", "-")&.capitalize
    end
    column :discount_pct do |card_order|
      card_order.discount_pct_to_str
    end
    column :discount_exp do |card_order|
      card_order.discount_exp_to_str
    end
    column :enabled
    column :international
    column :created_at
    column :updated_at
  end

  show title: proc{ "Campaign ##{@card_order.id}" } do
    attributes_table title: "Campaign Details" do
      row :shop do |card_order|
        card_order.shop
      end
      row :type  do |card_order|
        card_order.campaign_type&.gsub("_", "-")&.capitalize
      end
      row :discount_pct do |card_order|
        card_order.discount_pct_to_str
      end
      row :discount_exp do |card_order|
        card_order.discount_exp_to_str
      end
      row :enabled do |card_order|
          status_tag("#{card_order.enabled}")
          link_to "edit", change_sending_status_admin_card_order_path(card_order)
      end
      row :international
      row :created_at
      row :updated_at

      row :price_rules

      row :front_json do |card_order|
        JSON.pretty_generate(card_order.front_json) if card_order.front_json
      end
      row "front background_url", :front_json do |card_order|
        json = card_order.front_json
        link_to json['background_url'], json['background_url'], target: :_blank if json['background_url']
      end

      row :back_json do |card_order|
        JSON.pretty_generate(card_order.back_json) if card_order.back_json
      end

      row "back background_url", :back_json do |card_order|
        json = card_order.back_json
        link_to json['background_url'], json['background_url'], target: :_blank if json['background_url']
      end

      row "Old Card Side Front", :card_side_front
      row "Old Card Side Back", :card_side_back

      row :sample do |card_order|
          link_to "Send a sample", send_sample_admin_card_order_path(card_order, method: :get)
      end
    end

    panel "Filter Data" do
      table_for card_order.filters do
        column :id
        column :created_at
        column :updated_at
        column :card_order
        column :filter_data
      end
    end
  end
end
