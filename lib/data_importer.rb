
module DataImporter

  PAGE_SIZE = 250   # 250 maximum

  class Shop

    def initialize(shop_id)
      @shop = ::Shop.find(shop_id)
    end

    def import_orders(before_time, after_time)
      @shop.with_shopify_session do
        page_index = 1
        loop do
          Rails.logger.info "Fetching Orders from Shopify - page #{page_index}..."
          chunk = get_orders(page_index, after_time, before_time)
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
                processed_at_min: processed_at_min.iso8601,
                processed_at_max: processed_at_max.iso8601,
                page: index}
      orders = ShopifyAPI::Order.all(params: params)
    end
  end

end

