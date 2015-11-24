module SpecTestHelper
  def login(shop)
    session[:shopify] = shop.id
  end

  def current_shop
    Shop.find(session[:shopify])
  end

  def logout
    session[:shopify] = nil
  end
end
