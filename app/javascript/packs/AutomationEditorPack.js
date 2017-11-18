import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);

import AutomationEditor from '../containers/AutomationEditor'


// document.addEventListener('turbolinks:load', () => {
// });
// console.log('AutomationEditorPack.js');
// console.log(AutomationEditor);




// TODO: Add Vue Turbolinks mixin to fix hot reloading / dom caching
// https://github.com/turbolinks/turbolinks/wiki/VueJs-and-Turbolinks

document.addEventListener('turbolinks:load',  function load() {
  Vue.prototype.$http = axios;
  Vue.prototype.$http.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  // console.log(document.querySelector('meta[name="csrf-token"]').getAttribute('content'));

  var element = document.getElementById('automation-editor');
  if (element != null) {

    var id = element.dataset.id;
    var automation = JSON.parse(element.dataset.automation);
    var awsSignEndpoint = element.dataset.awsSignEndpoint;
    automation.card_side_front_attributes = JSON.parse(element.dataset.cardSideFrontAttributes);
    automation.card_side_back_attributes = JSON.parse(element.dataset.cardSideBackAttributes);

    // automation.card_side_front_attributes['image'] =
    // //   'https://touchcard-data.s3.amazonaws.com/uploads/5e53d741-4ad3-4e02-a8fc-bd5f91af1e05/thank-you-card-front5.jpg';

    var app = new Vue({
      el: element,
      data: function() {
        return {
          id: id,
          automation: automation,
          awsSignEndpoint: awsSignEndpoint,
          enableDiscount: true,
          newFrontImage: null,
          newFrontImageData: null,
          newBackImage: null,
          newBackImageData: null,
        };
      },
      methods: {
        saveAutomation: function() {

          // Upload new files, if necessary

          //   var promises = [];
          //   if (this.newFrontImage) {
          //     promises.push(uploadToS3(this.newFrontImage));
          //   }
          //   if (this.newBackImage) {
          //     promises.push(uploadToS3(this.newBackImage));
          //   }
          //
          //   Promise.all(promises)
          //     .then(function(results)=>{
          //     // Have URL, save automation
          //   })
          // .catch(function (err) {
          //     // console.log(err);
          //   });

          var vm = this;

          // Step 3. Callback to post the result
          function postForm() {
            // Create a new automation
            if (vm.id == null) {
              axios.post('/automations.json', { card_order: vm.automation})
                .then(function(response) {
                  console.log(response);
                  Turbolinks.visit('/automations');
                }).catch(function (error) {
                console.log(error);
              });
              // Edit existing automation
            } else {
              let target = `/automations/${vm.id}.json`;
              axios.put(target, { card_order: vm.automation })
                .then(function(response) {
                  console.log(response);
                  Turbolinks.visit('/automations');
                }).catch(function (error) {
                console.log(error);
              });
            }
          }

          // Step 2. Callback to upload back image
          function uploadBackImage() {
            if (vm.newBackImage) {
              vm.uploadFileToS3(vm.newBackImage, function(error, result){
                console.log(error);
                console.log(result);

                debugger;
                // CAREFUL - an exception here fails the promise from which we call this callback
                if (result) {
                  automation.card_side_back_attributes.image = result;
                  postForm();
                }
              });
            } else {
              postForm();
            }
          }

          // Step 1. Start by uploading back image
          if (this.newFrontImage) {
            this.uploadFileToS3(this.newFrontImage, function(error, result){
              console.log(error);
              console.log(result);

              // CAREFUL - an exception here fails the promise from which we call this callback
              if (result) {
                automation.card_side_front_attributes.image = result;
                uploadBackImage();
              }
            });
          } else {
            uploadBackImage();
          }

        },
        // TODO: Refactor to combine Front & Back
        onNewBackImage(e) {
          var files = e.target.files || e.dataTransfer.files;
          if (!files.length)
            return;
          this.newBackImage = files[0];

          var vm = this;
          this.createImage(this.newBackImage, function(fileData){ vm.newBackImageData = fileData;});
        },
        // TODO: Refactor to combine Front & Back
        onNewFrontImage(e) {
          var files = e.target.files || e.dataTransfer.files;
          if (!files.length)
            return;
          this.newFrontImage = files[0];

          var vm = this;
          this.createImage(this.newFrontImage, function(fileData){ vm.newFrontImageData = fileData;});
        },
        createImage(file, onLoad) {
          var image = new Image();
          var reader = new FileReader();
          var vm = this;

          reader.onload = function load(e) {
            // console.log(e.target.result);
            onLoad(e.target.result);
          };
          reader.readAsDataURL(file);
        },
        uploadFileToS3: function(file, callback) {
          if (typeof this.awsSignEndpoint == 'undefined'){
            throw 'Missing Upload URL';
          }
          // Get S3 Upload URL from Touchcard Server
          axios.get(this.awsSignEndpoint, {
            params: {
              name: file.name,
              type: file.type
            }
          })
            .then(function (result) {
              console.log(result)
              var signedUrl = result.data.signedUrl;

              var options = {
                headers: {
                  'Content-Type': file.type
                }
              };
              // Upload File to S3
              axios.put(signedUrl, file, options)

              // transformResponse: [function (data) {
              //   // Do whatever you want to transform the data
              //
              //   return data;
              // }],
              //
                .then(function (result) {
                  console.log(result);
                  var imageUrl = result.request.responseURL && result.request.responseURL.split('?')[0];
                  if (typeof callback === "function") {
                    callback(null, imageUrl);
                  }
                })
                .catch(function (err) {
                  console.log(err);
                  if (typeof callback === "function") {
                    callback(err);
                  }
                });
            })
            .catch(function (err) {
              console.log(err)
            });
        }
      }
    });

    window.tc = app;

    console.log('Vue Loaded');
  }
});

