
module DataImporter

  PAGE_SIZE = 250   # 250 maximum

  class Shop

    def initialize(shop_id)
      @shop = ::Shop.find(shop_id)
    end

    def import_orders(before_date = Time.now, lookback_days = 1)
      @shop.with_shopify_session do
        page_index = 1
        after_date = before_date - lookback_days.days
        loop do
          Rails.logger.info "Fetching Orders from Shopify - page #{page_index}..."
          chunk = get_orders(page_index, after_date, before_date)
          for order in chunk do
            begin
              Order.from_shopify!(order, @shop)
            rescue ActiveRecord::RecordInvalid => e
              if e.message == 'Validation failed: Shopify has already been taken'
                Rails.logger.warn "#{e.message}"
                next
              else
                raise e
              end
            end
          end
          break if chunk.count < PAGE_SIZE
          page_index += 1
        end
      end
    end

    def get_orders(index, processed_at_min, processed_at_max)

      # https://help.shopify.com/api/reference/order#index
      # shop_id, since_id, page, status ="any", processed_at_min, processed_at_max
      # shop = Shop.find_by(domain: shop_domain)

      params = {status: "any",
                limit: PAGE_SIZE,
                processed_at_min: processed_at_min,
                processed_at_max: processed_at_max ,
                page: index}
      orders = ShopifyAPI::Order.all(params: params)
    end
  end

end

