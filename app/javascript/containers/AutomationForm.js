/* global Turbolinks */
import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'
import * as api from '../Api'
// import CardEditor from '../components/CardEditor'


import { fabric }from 'fabric-browseronly'

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
        canvas: null,
        originalCanvasHeight: 1275,
        originalCanvasWidth: 1875,
      };
    },
    beforeDestroy: function () {
      window.removeEventListener('resize', this.handleResize)
    },
    mounted: function() {
      // console.log('Mounted');
      // this.$nextTick(function () {
      // code that assumes this.$el is in-document
      // });

      // create a wrapper around native canvas element (with id="c")
      this.canvas = new fabric.Canvas('card-editor', { stateful: true });
      let rect = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
      this.canvas.add(rect);


      this.canvas.on('object:moving', this.handleObjectMoved);

      window.addEventListener('resize', this.handleResize);

      this.handleResize();

      // document.addEventListener('resize', () => { console.log('RESIZING'); });

    },
    // components: {
    //   'card-editor': CardEditor
    // },
    methods: {
      handleObjectMoved: function(e) {
        var obj = e.target;

        console.log('x      : ' + obj.left + ' y      :' + obj.top);

        console.log('x bound: ' + obj.getBoundingRect().left + ' y bound:' + obj.getBoundingRect().top);

        // if object is too big ignore
        // if(obj.currentHeight > obj.canvas.height || obj.currentWidth > obj.canvas.width){
        //   return;
        // }
        // obj.setCoords();

        if (obj.top < 0) {
          obj.top = 0;
        }
        if (obj.left < 0) {
          obj.left = 0;
        }

        if (obj.top + obj.height > this.originalCanvasHeight) {
          obj.top = this.originalCanvasHeight - obj.height;
        }

        if (obj.left + obj.width > this.originalCanvasWidth) {
          obj.left = this.originalCanvasWidth - obj.width;
        }


        // Solution from here: https://stackoverflow.com/a/24238960/1181104
        // but bounding box isn't updating properly after canvas resize:


      },
      handleResize: function() {

        let ratio = (Math.min(this.originalCanvasWidth/2, window.innerWidth)/ 1875) * 0.90;

        this.canvas.setDimensions({ width: this.originalCanvasWidth * ratio, height: this.originalCanvasHeight * ratio });
        this.canvas.setZoom(ratio);
      },
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