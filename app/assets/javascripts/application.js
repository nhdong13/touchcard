// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require material
//= require turbolinks
//= require vue
//= require_tree .

// console.log('Adding Event Listener - application.js');

// Make turbolinks work with material framework
document.addEventListener('turbolinks:load', function() {
  // console.log('turbolinks:load - application.js');
  componentHandler.upgradeDom();
});

window.onload = function() {
  // console.log('window.onload - application.js');
  ShopifyApp.Bar.loadingOff();
};

// document.addEventListener('DOMContentLoaded', () => {
//   console.log('DOMContentLoaded - application.js');
// });



// TODO: Add Vue Turbolinks mixin to fix hot reloading / dom caching
// https://github.com/turbolinks/turbolinks/wiki/VueJs-and-Turbolinks
document.addEventListener('turbolinks:load', () => {
  var element = document.getElementById("vueEnabledCardEditor");
  if (element != null) {

    var cardEditor = new Vue({
      el: '#vueEnabledCardEditor',
      data: {
        enableDiscount: true
      }
    });

    // var vueapp = new Vue({
    //   el: element,
    //   template: '<App/>',
    //   components: { App }
    // });
  }
});



