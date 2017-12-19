<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    Select an image: <input type="file" accept="image/png,image/jpeg"  v-on:change="onUpdateFrontBackground">
    <button v-on:click="front.addDiscount()">Add Discount</button>
    <button v-on:click="front.removeDiscount()">Remove Discount</button>
    <!--<input type="checkbox" v-model="enableFrontDiscount">-->
    <br>
    <canvas id="front-side-canvas" class="card-side-canvas" width=1875 height=1275></canvas>
    <br>
    Select an image: <input type="file" accept="image/png,image/jpeg"  v-on:change="onUpdateBackBackground">
    <br>
    <canvas id="back-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
  </div>
</template>

<script>
  import { fabric } from 'fabric-browseronly'
  import { Api } from '../api';
  import { CardSide } from './card_side';

  const FullCanvasWidth = 1875;
  const FullCanvasHeight = 1275;

  export default {
    props: {
      front_attributes: {
        type: Object,
        required: true
      },
      back_attributes: {
        type: Object,
        required: true
      },
      aws_sign_endpoint: {
        type: String,
        required: true
      }
    },
    data: function() {
      return {
        front: null,
        back: null,
        enableFrontDiscount: false,
        enableBackDiscount: false,
      }
    },
    // watch: {
    //   enableFrontDiscount: function(val) {
    //
    //   },
    //   enableBackDiscount: function(val) {
    //     this.automation.card_side_front_attributes = val;
    //     this.automation.card_side_back_attributes = val;
    //   }
    // },
    mounted: function() {
      console.log('CardEditor Mounted')
      // this.$nextTick(function () {
      // code that assumes this.$el is in-document
      // });
      this.api = new Api(this.aws_sign_endpoint)
      this.front = new CardSide(this.front_attributes, 'front-side-canvas', FullCanvasWidth, FullCanvasHeight);
      this.back = new CardSide(this.back_attributes, 'back-side-canvas', FullCanvasWidth, FullCanvasHeight);

      this.handleResize();
      window.addEventListener('resize', this.handleResize);

      window.card_editor = this;
    },
    beforeDestroy: function () {
      window.removeEventListener('resize', this.handleResize)
    },
    methods: {
      requestSave: function() {

        // TODO: We should probably have a data structure to monitor parallel uploads + completion
        // And would be nice if uploads happened as soon as added + CardSide has loading icon + completion for not-yet-uploaded images
        let promises = [];
        if (this.front.newImage) {
          promises.push(this.uploadNewBackground(this.front));
        }
        if (this.back.newImage) {
          promises.push(this.uploadNewBackground(this.back));
        }
        return Promise.all(promises);
      },
      uploadNewBackground: function(cardSide) {
        return new Promise((resolve, reject)=> {
          this.api.uploadFileToS3(cardSide.newImage, (error, result) => {
            console.log(error ? error : result);
            if (result) {
              cardSide.attrs.image = result;
              return resolve();
            }
            reject();
          });
        });
      },
      handleResize: function() {
        let ratio = (Math.min(FullCanvasWidth/2, window.innerWidth)/ FullCanvasWidth) * 0.9;
        this.front.resizeCanvas(ratio);
        this.back.resizeCanvas(ratio);
      },
      onUpdateFrontBackground: function(e) {
        this.updateBackground(e, this.front)
      },
      onUpdateBackBackground: function(e) {
        this.updateBackground(e, this.back)
      },
      updateBackground: function(e, cardSide) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        cardSide.updateBackground(files[0]);
      },
    }
  }
</script>

<style scoped>

  /* Required for Coupon used by card_side.js */
  @import url('https://fonts.googleapis.com/css?family=Montserrat');

  p {
    font-size: 2em;
    text-align: center;
  }

</style>

