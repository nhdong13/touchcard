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
  history.dispatch(History.Action.REPLACE, data.path);
})
