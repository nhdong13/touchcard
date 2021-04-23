class DuplicateCampaignService
  def initialize current_shop, params
    @params = params
    @current_shop = current_shop
    @card_order = CardOrder.where(id: params["campaign_id"]).last
  end

  def duplicate
    # create clone card_order
    return unless @card_order
    card_order_clone = @card_order.dup
    card_order_clone.name = "#{@card_order.name} clone"
    card_order_clone.enabled = false
    card_order_clone.save(validate: false)
    clone_front_card_sides(card_order_clone)
    clone_back_card_sides(card_order_clone)
    clone_filters(card_order_clone)
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