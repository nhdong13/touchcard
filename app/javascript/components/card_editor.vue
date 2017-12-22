<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    <!--<button v-on:click="front.addDiscount()">Add Discount</button>-->
    <!--<button v-on:click="front.removeDiscount()">Remove Discount</button>-->
    <div class="card-side-editor-container">

      <div class="card-side-aspect-padder">
        <card-side
            ref="frontSide"
            :backgroundUrl="frontBackgroundImageUrl"
            :enableDiscount="enableFrontDiscount"

        >
        </card-side>
      </div>

      <!--<div class="canvas-container-wrapper">-->
        <!--<canvas id="front-side-canvas" class="card-side-canvas" width=1875 height=1275></canvas>-->
      <!--</div>-->
      <div class="flex-spacer"></div>
      <div class="editor-menu">
        <strong>Upload Background</strong>
        <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event, front)">
        <hr />
        <input type="checkbox" v-model="enableFrontDiscount"><strong>Include Expiring Discount</strong>
        <div class="discount-config" v-if="enableFrontDiscount">
          <span><input type="number" min="0" max="100" v-model="globalDiscountPct"> % off</span><br>
          <span><input type="number" min="1" max="52" v-model="globalDiscountExp"> weeks expiration</span>
        </div>
      </div>
    </div>
    <br>
  </div>
</template>

<script>
  import { Api } from '../api';
  import CardSide from './card_side.vue';

  // const FullCanvasWidth = 1875;
  // const FullCanvasHeight = 1275;

  export default {
    props: {
      discount_pct: {
      },
      discount_exp: {
      },
      aws_sign_endpoint: {
        type: String,
        required: true
      }
    },
    mounted: function () {
      debugger;
    },
    components:{
      'card-side': CardSide
    },
    data: function() {
      return {
        front: null,
        back: null,
        frontBackgroundImageUrl: null,
        enableFrontDiscount: false,
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

    },
    mounted: function() {
      console.log('CardEditor Mounted')
      // this.$nextTick(function () {
      // code that assumes this.$el is in-document
      // });
      this.api = new Api(this.aws_sign_endpoint)

      window.card_editor = this;
    },
    methods: {
      requestSave: function() {
        //
        // // TODO: We should probably have a data structure to monitor parallel uploads + completion
        // // And would be nice if uploads happened as soon as added + CardSide has loading icon + completion for not-yet-uploaded images
        // let promises = [];
        // if (this.front.newImage) {
        //   promises.push(this.uploadNewBackground(this.front));
        // }
        // if (this.back.newImage) {
        //   promises.push(this.uploadNewBackground(this.back));
        // }
        // return Promise.all(promises);
      },
      updateBackground: function(e, cardSide) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        // TODO: Upload progress (perhaps embedded in dynamic Canvas img/object that doesn't save?)
        // TODO: Block Saving while files are uploading
        this.api.uploadFileToS3(files[0], (error, result) => {
          console.log(error ? error : result);
          if (result) {
            this.frontBackgroundImageUrl = result;
          }
        });
      },
    }
  }
</script>

<style scoped>

  p {
    font-size: 2em;
    text-align: center;
  }

  /*.canvas-container-wrapper {*/
  /*}*/

  .card-side-editor-container {
    display: flex;
    padding: 10px;
    /*margin: 20px;*/
    background: lightsalmon;
  }

  /*!* https://stackoverflow.com/questions/1495407/maintain-the-aspect-ratio-of-a-div-with-css *!*/
  .card-side-aspect-padder {
    width: 100%;
    /*padding-bottom: 68%;*/
    position: relative;
    background: lightblue; /** <-- For the demo **/
  }

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

