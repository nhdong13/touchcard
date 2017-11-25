import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'

import * as api from '../Api'


export default function loadAutomationEditor (element) {

  var id = element.dataset.id;
  var automation = JSON.parse(element.dataset.automation);
  var awsSignEndpoint = element.dataset.awsSignEndpoint;
  automation.card_side_front_attributes = JSON.parse(element.dataset.cardSideFrontAttributes);
  automation.card_side_back_attributes = JSON.parse(element.dataset.cardSideBackAttributes);

  return new Vue({
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
    // mounted: function () {
    //   this.$nextTick(function () {
    //     // Code that will run only after the
    //     // entire view has been rendered
    //     console.log('\n\n\n=== VUE MOUNTED ===\n\n\n');
    //   })},
    // destroyed: function () {
    //   this.$nextTick(function () {
    //     // Code that will run only after the
    //     // entire view has been rendered
    //     console.log('\n\n\n=== VUE DESTROYED ===\n\n\n');
    //   })},
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
            api.uploadFileToS3(this.awsSignEndpoint, vm.newBackImage, function(error, result){
              console.log(error);
              console.log(result);

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
          api.uploadFileToS3(this.awsSignEndpoint, this.newFrontImage, function(error, result){
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
      onNewBackImage(e) {
        var files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.newBackImage = files[0];
        var vm = this;
        this.createImage(this.newBackImage, function(fileData){ vm.newBackImageData = fileData;});
      },
      onNewFrontImage(e) {
        var files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.newFrontImage = files[0];
        var vm = this;
        this.createImage(this.newFrontImage, function(fileData){ vm.newFrontImageData = fileData;});
      },
      createImage(file, onLoad) {
        var reader = new FileReader();
        reader.onload = function load(e) {
          onLoad(e.target.result);
        };
        reader.readAsDataURL(file);
      }
    }
  });
}