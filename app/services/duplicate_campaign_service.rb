class DuplicateCampaignService
  def initialize current_shop, campaign_id
    @current_shop = current_shop
    @card_order = CardOrder.find_by(id: campaign_id)
  end

  def duplicate duplicate_campaign_name
    # create clone card_order
    return unless @card_order
    card_order_clone = @card_order.dup
    dup_campaign_name = generate_campaign_name(duplicate_campaign_name)
    card_order_clone.campaign_name = dup_campaign_name
    card_order_clone.card_order_parent_id = @card_order.id
    card_order_clone.enabled = false
    card_order_clone.campaign_status = "draft"
    card_order_clone.send_date_start = ( Time.now.end_of_day >= @card_order.send_date_start ) ? Time.now : @card_order.send_date_start
    unless card_order_clone.send_continuously
      if Time.now.end_of_day >= @card_order.send_date_end
        card_order_clone.send_date_end = nil
        card_order_clone.send_continuously = true
      else
        card_order_clone.send_date_end = @card_order.send_date_end
      end
    end
    card_order_clone.save(validate: false)
    clone_front_card_sides(card_order_clone)
    clone_back_card_sides(card_order_clone)
    clone_filters(card_order_clone)
  end


  def generate_campaign_name duplicate_campaign_name
    return duplicate_campaign_name if duplicate_campaign_name.present?
    number = @card_order.copies.count
    clone_campaign_name = number > 0 ? "Copy #{number + 1} of #{@card_order.campaign_name}" : "Copy of #{@card_order.campaign_name}"
    clone_campaign_name = @card_order.campaign_name if clone_campaign_name.length > MAXIMUM_CAMPAIGN_NAME_LENGTH
    clone_campaign_name
  end

  def clone_front_card_sides card_order_clone
    card_side_front = @card_order.card_side_front
    card_side_front_clone = card_side_front.dup
    card_side_front_clone.card_order_id = card_order_clone.id
    card_side_front_clone.save
  end

  def clone_back_card_sides card_order_clone
    card_side_back = @card_order.card_side_back
    card_side_back_clone = card_side_back.dup
    card_side_back_clone.card_order_id = card_order_clone.id
    card_side_back_clone.save
  end

  def clone_filters card_order_clone
    filters = @card_order.filters
    filters.each do |filter|
      filter_clone = filter.dup
      filter_clone.card_order_id = card_order_clone.id
      filter_clone.save(validate: false)
    end
  end
end