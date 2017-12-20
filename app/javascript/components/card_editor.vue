<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    <!--<button v-on:click="front.addDiscount()">Add Discount</button>-->
    <!--<button v-on:click="front.removeDiscount()">Remove Discount</button>-->
    <div class="card-side-container">
      <div class="canvas-container-wrapper">
        <canvas id="front-side-canvas" class="card-side-canvas" width=1875 height=1275></canvas>
      </div>
      <div class="flex-spacer"></div>
      <div class="editor-menu">
        <strong>Upload Background</strong>
        <input type="file" accept="image/png,image/jpeg"  v-on:change="onUpdateFrontBackground">
        <hr />
        <input type="checkbox" v-model="enableFrontDiscount"><strong>Include Expiring Discount</strong>
        <div class="discount-config" v-if="enableFrontDiscount">
          <span><input type="number" min="0" max="100" v-model="globalDiscountPct"> % off</span><br>
          <span><input type="number" min="1" max="52" v-model="globalDiscountExp"> weeks expiration</span>
        </div>
      </div>
    </div>
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
      discount_pct: {
      },
      discount_exp: {
      },
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
        enableFrontDiscount: null,
        enableBackDiscount: null,
        globalDiscountPct: this.discount_pct,
        globalDiscountExp: this.discount_exp,
      }
    },
    watch: {
      globalDiscountPct: function(val) {
        this.$emit('update:discount_pct', val);
      },
      globalDiscountExp: function(val) {
        this.$emit('update:discount_exp', val);
      },
      // TODO: For backwards-compatability's sake we would like to null out card_order.discount_pct and
      // card_order.discount_exp if neither card side has a discount, but that may just complicate
      // things without being absolutely necessary
      //
      // enableFrontDiscount: function(val) {
      // },
      // enableBackDiscount: function(val) {
      // }
    },
    mounted: function() {
      console.log('CardEditor Mounted')
      // this.$nextTick(function () {
      // code that assumes this.$el is in-document
      // });
      this.api = new Api(this.aws_sign_endpoint)
      this.front = new CardSide(this.front_attributes, 'front-side-canvas', FullCanvasWidth, FullCanvasHeight);
      this.back = new CardSide(this.back_attributes, 'back-side-canvas', FullCanvasWidth, FullCanvasHeight);
      // this.enableFrontDiscount = this.front_attributes

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
        // TODO: get dynamically from CSS
        const MenuWidth = 180;
        let ratio = Math.min(620/FullCanvasWidth, Math.max(320/FullCanvasWidth, (Math.min(FullCanvasWidth/2, window.innerWidth - MenuWidth)/ FullCanvasWidth) * 0.8));
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

  /*.canvas-container-wrapper {*/
  /*}*/

  .card-side-container {
    display: flex;
    padding: 10px;
    /*margin: 20px;*/
    background: #fff0da;
  }

  /* Fabric.js adds a canvas-container around the canvas */
  /*.canvas-container { }*/

  .card-side-canvas {
    border-width: 1px;
    border-color: grey;
    border-style: dashed;
  }

  .flex-spacer {
    flex-grow: 0;
    flex-shrink: 0;
    flex-basis: 10px;
  }
  .editor-menu {
    background: lightgrey;
    flex-grow: 0;
    flex-shrink: 0;
    flex-basis: 180px;
    padding: 10px;
  }

  .discount-config {
    padding-top: 10px;
    padding-left: 10px;
  }


</style>

