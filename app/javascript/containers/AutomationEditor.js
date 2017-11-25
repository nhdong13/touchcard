/* global Turbolinks */

import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'

import * as api from '../Api'

export default function loadAutomationEditor (element) {

  let id = element.dataset.id;
  let automation = JSON.parse(element.dataset.automation);
  let awsSignEndpoint = element.dataset.awsSignEndpoint;
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
    methods: {
      saveAutomation: function() {
        let promises = [];
        if (this.newFrontImage) {
          promises.push(this.uploadFrontImage());
        }
        if (this.newBackImage) {
          promises.push(this.uploadBackImage());
        }
        Promise.all(promises).then((results) => {
          console.log(results);
          this.postOrPutForm();
        })
          .catch(function (err) {
            console.log(err);
          });
      },
      postOrPutForm: function() {

        if (this.id) {
          // Edit existing automation (PUT)
          let target = `/automations/${this.id}.json`;
          axios.put(target, { card_order: this.automation })
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
        } else {
          // Create a new automation (POST)
          axios.post('/automations.json', { card_order: this.automation})
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
        }
      },
      uploadBackImage: function() {
        return new Promise((resolve, reject)=> {
          api.uploadFileToS3(this.awsSignEndpoint, this.newBackImage, (error, result) => {
            console.log(error ? error : result);
            if (result) {
              automation.card_side_back_attributes.image = result;
              return resolve();
            }
            reject();
          });
        });
      },
      uploadFrontImage: function() {
        return new Promise((resolve, reject)=> {
          api.uploadFileToS3(this.awsSignEndpoint, this.newFrontImage, (error, result) => {
            console.log(error ? error : result);
            if (result) {
              automation.card_side_front_attributes.image = result;
              return resolve();
            }
            reject();
          });
        });
      },
      onNewBackImage: function(e) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.newBackImage = files[0];
        this.createImage(this.newBackImage, (fileData) => { this.newBackImageData = fileData;});
      },
      onNewFrontImage: function(e) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.newFrontImage = files[0];
        this.createImage(this.newFrontImage, (fileData) => { this.newFrontImageData = fileData;});
      },
      createImage: function(file, onLoad) {
        let reader = new FileReader();
        reader.onload = (e) => {
          onLoad(e.target.result);
        };
        reader.readAsDataURL(file);
      }
    }
  });
}