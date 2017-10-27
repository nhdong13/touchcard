
// TODO: Add Vue Turbolinks mixin to fix hot reloading / dom caching
// https://github.com/turbolinks/turbolinks/wiki/VueJs-and-Turbolinks
document.addEventListener('turbolinks:load', function() {
  var element = document.getElementById("vueEnabledCardEditor");
  if (element != null) {

    var cardEditor = new Vue({
      el: '#vueEnabledCardEditor',
      data: {
        enableDiscount: true
      },
      methods: {
        // TODO: Code below has uglifier compile issues when deployed to Heroku
        //
        fileChanged: function(e) {
          var file = e.target.files[0].name,
            signedUrl = e.target.form.dataset.url,
            data = JSON.parse(e.target.form.dataset.formData),
            options = {
              headers: {
                'Content-Type': 'multipart/form-data'
              }
            };

          var formData = new FormData();
          for ( i in data ) {
            formData[i] = data[i];
          }
          formData['file'] = file;
          axios.put(signedUrl, formData, options)
            .then(function(result) {
              debugger;
            })
            .catch(function(result) {
              debugger;
            });
        }
      }
    });

    // var vueapp = new Vue({
    //   el: element,
    //   template: '<App/>',
    //   components: { App }
    // });
  }
});



