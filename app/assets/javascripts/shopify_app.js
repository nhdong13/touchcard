document.addEventListener('DOMContentLoaded', () => {
  var data = document.getElementById('shopify-app-init').dataset;
  var createApp = AppBridge.default;
  window.app = createApp({
    apiKey: data.apiKey,
    shopOrigin: data.shopOrigin,
  });
  var TitleBar = actions.TitleBar;
  TitleBar.create(app, {
    title: data.page,
  });
});

document.addEventListener('turbolinks:load', () => {
  var data = document.getElementById('shopify-app-init').dataset;
  var History = actions.History;
  const history = History.create(app);
  var path = data.path;
  if (path.includes("hmac=")) {
    var path = data.path.split("&").filter(
      p => !(p.includes('hmac=') || p.includes('host=') || p.includes('locale=') || p.includes('session=') || p.includes('shop=') || p.includes('timestamp='))).join("&");
    path = "/?" + path;
  };
  history.dispatch(History.Action.REPLACE, path)
})
