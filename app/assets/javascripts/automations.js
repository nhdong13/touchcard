
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
        fileChanged: function(e) {
          var file = e.target.files[0];
          var image_url = '';
          axios.get('https://touchcard.ngrok.io/aws/sign', {
            params: {
              name: file.name,
              type: file.type
            }
          })
            .then(function (result) {
              // console.log(result)
              // debugger;
              var signedUrl = result.data.signedUrl;
              image_url = result.data.url;
              var options = {
                headers: {
                  'Content-Type': file.type,
                  'acl': 'public-read'
                }
              };
              return axios.put(signedUrl, file, options);
            })
            .then(function (result) {
              // console.log(result);
              // console.log(image_url);
              // debugger;
            })
            .catch(function (err) {
              // console.log(err);
              // debugger;
            });
        }
      }
    });

  }
});
