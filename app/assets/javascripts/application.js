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

// Organization tips: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/

// --- Libraries ---
//= require rails-ujs
//= require material-components-web
//= require turbolinks

// --- Application ---
// # Disabled so we can define load order: `require_tree .`
// # also keeps activeadmin from loading, I think
//= require init
//= require shopify_app
//= require flash_messages
