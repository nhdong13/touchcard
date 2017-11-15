
// TODO: Add Vue Turbolinks mixin to fix hot reloading / dom caching
// https://github.com/turbolinks/turbolinks/wiki/VueJs-and-Turbolinks

document.addEventListener('turbolinks:load', function() {
  Vue.prototype.$http = axios;
  Vue.prototype.$http.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  // console.log(document.querySelector('meta[name="csrf-token"]').getAttribute('content'));

  var element = document.getElementById('automation-editor');
  if (element != null) {

    var id = element.dataset.id;
    var automation = JSON.parse(element.dataset.automation);

    var app = new Vue({
      el: element,
      // mixins: [TurbolinksAdapter],
      data: function() {
        return {
          id: id,
          automation: automation,
          enableDiscount: true,
        };
      },
      methods: {
        saveAutomation: function() {
          // Create a new automation
          if (this.id == null) {
            this.$http.post('/automations.json', { card_order: this.automation}).then(function(response) {
              // debugger;
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
            // Edit existing automation
          } else {
            target = `/automations/${this.id}.json`;
            this.$http.put(target, { card_order: this.automation }).then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
          }
        }
      }
    });

    window.tc = app;

    console.log('Vue Loaded');
  }
});





//
// document.addEventListener('turbolinks:load', function() {
//   var element = document.getElementById("vueEnabledCardEditor");
//   if (element != null) {
//
//     var cardEditor = new Vue({
//       el: '#vueEnabledCardEditor',
//       data: {
//         enableDiscount: true
//       },
//       methods: {
//         fileChanged: function(e) {
//           var file = e.target.files[0];
//           var image_url = '';
//           axios.get('https://touchcard.ngrok.io/aws/sign', {
//             params: {
//               name: file.name,
//               type: file.type
//             }
//           })
//             .then(function (result) {
//               // console.log(result)
//               // debugger;
//               var signedUrl = result.data.signedUrl;
//               image_url = result.data.url;
//               var options = {
//                 headers: {
//                   'Content-Type': file.type
//                 }
//               };
//               return axios.put(signedUrl, file, options);
//             })
//             .then(function (result) {
//               // console.log(result);
//               // console.log(image_url);
//               // debugger;
//             })
//             .catch(function (err) {
//               // console.log(err);
//               // debugger;
//             });
//         }
//       }
//     });
//
//   }
// });
//


