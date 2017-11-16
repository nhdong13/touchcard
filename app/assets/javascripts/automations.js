
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

    console.log(automation);
    var awsSignEndpoint = element.dataset.awsSignEndpoint;

    // automation.card_side_front_attributes = {};
    // automation.card_side_back_attributes = {};
    // // automation.card_side_front_attributes['image'] =
    // //   'https://touchcard-data.s3.amazonaws.com/uploads/5e53d741-4ad3-4e02-a8fc-bd5f91af1e05/thank-you-card-front5.jpg';

    var app = new Vue({
      el: element,
      // mixins: [TurbolinksAdapter],
      data: function() {
        return {
          id: id,
          automation: automation,
          awsSignEndpoint: awsSignEndpoint,
          enableDiscount: true,
          frontSideImage: null,
          frontSideImageUrl: null,
          backSideImage: null,
          backSideImageUrl: null,
        };
      },
      watch: {
        frontSideImage: function (newImage) {
          // AND NOW DO THIS --- TODO:
          // whenever frontSideImage changes (user action)
          // upload it to S3, block the respective SAVE and CHOOSE FILE buttons
          //
          // when that's done, set the backSideImageURL, which  unblocks the SAVE and CHOOSEFILE buttons
          //
          // SAVE must stay blocked if two images are uploading and one finishes...
          //
          // Alternatively... may be simpler if we do a full upload on save
          // otherwise we may need the option to cancel an upload
          //
          // File input
          // https://forum.vuejs.org/t/vuejs2-file-input/633/3
          // https://codepen.io/Atinux/pen/qOvawK
          //
        }
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
        },
        onFrontImageFileChange(e) {
          var files = e.target.files || e.dataTransfer.files;
          if (!files.length)
            return;
          var vm = this;
          this.createImage(files[0], function(fileData){ vm.frontSideImage = fileData;});
        },
        createImage(file, onLoad) {
          var image = new Image();
          var reader = new FileReader();
          debugger;
          var vm = this;

          reader.onload = (e) => {
            debugger;
            console.log(e.target.result);
            onLoad(e.target.result);
          };
          reader.readAsDataURL(file);
        },
        removeImage: function (e) {
          this.frontSideImage = null;
        },
        uploadFilesToS3: function() {
          var file = this.uploadFile;

          if (typeof this.awsSignEndpoint == 'undefined'){
            throw 'Missing Upload URL';
          }
          axios.get(this.awsSignEndpoint, {
            params: {
              name: file.name,
              type: file.type
            }
          })
            .then(function (result) {
              // console.log(result)
              var signedUrl = result.data.signedUrl;

              // var options = {
              //   headers: {
              //     'Content-Type': file.type
              //   }
              // };
              // axios.put(signedUrl, file, options)
              //   .then(function (result) {
              //     console.log(result);
              //     var imageUrl = result.request.responseURL && result.request.responseURL.split('?')[0];
              //
              //     automation.card_side_front_attributes['image'] = imageUrl;
              //
              //   })
              //   .catch(function (err) {
              //     // console.log(err);
              //     // debugger;
              //   });
            })
            .catch(function (err) {
              // console.log(err)
            });
        }
      }
    });

    window.tc = app;

    console.log('Vue Loaded');
  }
});

