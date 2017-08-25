
module DataImporter

  PAGE_SIZE = 100   # 250 maximum

  class Shop

    def initialize(shop_id)
      @shop = ::Shop.find(shop_id)
    end

    def import_orders()
      @shop.with_shopify_session do
        page_index = 1
        loop do
          chunk = get_orders(page_index,3)
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


    def get_orders(index, lookback_days=30)

      created_at_min = Time.now.midnight - lookback_days.days

      # https://help.shopify.com/api/reference/order#index
      # shop_id, since_id, page, status ="any", processed_at_min, processed_at_max
      # shop = Shop.find_by(domain: shop_domain)
      params = {status: "any", limit: PAGE_SIZE, created_at_min: created_at_min, page: index}
      orders = ShopifyAPI::Order.all(params: params)
    end
  end

end

