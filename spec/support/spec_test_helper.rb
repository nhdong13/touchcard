module SpecTestHelper
  def login(shop)
    shop = Shop.find_by(id: shop.id)
    session[:shopify] = shop.id
  end

  def current_shop
    Shop.find(request.session[:shopify])
  end

  def logout
    session[:shopify] = nil
  end
end
