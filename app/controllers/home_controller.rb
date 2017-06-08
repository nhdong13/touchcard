class HomeController < ShopifyApp::AuthenticatedController
  def index
    render text: "Oops! If you get stuck here we messed up somehow :( Please let us know! support@touchcard.co"
  end
end
