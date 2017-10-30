
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
          var file = e.target.files[0].name,
            signedUrl = e.target.form.dataset.url,
            data= JSON.parse(e.target.form.dataset.formData),
            options = {
              headers: {
                'Content-Type': 'multipart/form-data'
              }
            };

          // TODO: AND NOW DO THIS
          // We're uploading to the bucket URL, https://touchcard-data-dev.s3.amazonaws.com/
          // not to the presigned URL
          // We need to make sure the path + filename are appended


          // var formData = new FormData();
          // for ( i in data ) {
          //   formData[i] = data[i];
          // }
          // formData['file'] = file;
          debugger;
          uploadPath = signedUrl + '/' + data.key;
          axios.put(uploadPath, data, options)
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


// const data = new FormData();
//
// data.append('action', 'ADD');
// data.append('param', 0);
// data.append('secondParam', 0);
// data.append('file', new Blob(['test payload'], { type: 'text/csv' }));
//
// axios.post('http://httpbin.org/post', data);





