/* global ShopifyApp */


function stopShopifyLoadingBar() {
  console.log('ShopifyApp.Bar.loadingOff()');
  ShopifyApp.Bar.loadingOff();
}

// window.onload = function() {
//   stopShopifyLoadingBar();
//
// // ShopifyApp.ready(function(){
// //   ShopifyApp.Bar.initialize({
// //     title: "Dashboard",
// //     icon: "<%= asset_path('favicon.png') %>"
// //   });
// // });
//
// };


// document.addEventListener('turbolinks:load', stopShopifyLoadingBar);
