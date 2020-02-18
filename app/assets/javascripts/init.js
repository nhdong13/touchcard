/* global ShopifyApp */


function stopShopifyLoadingBar() {
  console.log('ShopifyApp.Bar.loadingOff()');
  ShopifyApp.Bar.loadingOff();
}

// window.onload = function() {
//   stopShopifyLoadingBar();
//
// // ShopifyApp.ready(function(){
// //   ShopifyApp.Bar.initialize({ title: "Dashboard" });
// // });
//
// };


// document.addEventListener('turbolinks:load', stopShopifyLoadingBar);
