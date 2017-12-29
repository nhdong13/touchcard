<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    <div class="editor-columns-container">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
            ref="frontSide"
            :backgroundUrl="frontBackgroundImageUrl"
            :enableDiscount="enableFrontDiscount"
            :scaleFactor="cardScaleFactor"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
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
    // computed: {
    //   cardSideStyle: function() {
    //     return {
    //       margin: '0 auto',
    //       'transform-origin': 'left',
    //       transform: `scale(${this.viewScale})`
    //     }
    //   }
    // },
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
        cardScaleFactor: 1.0
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

      this.handleResize();
      window.addEventListener('resize', this.handleResize);
      window.card_editor = this;

    },
    beforeDestroy: function () {
      window.removeEventListener('resize', this.handleResize)
    },
    methods: {
      handleResize: function() {
        let leftColumnWidth = this.$refs.editorLeftColumn.offsetWidth;
        let cardWidth = this.$refs.frontSide.$el.offsetWidth // Expecting 6.25in * 96 px = 608
        this.cardScaleFactor = Math.max(0.1, Math.min(1.0, leftColumnWidth / cardWidth));

        // this.$refs.frontSide.style.transform = `scale(${scale})`;
        // this.$refs.frontSide.style['-o-transform'] = `scale(${scale})`;
        // this.$refs.frontSide.style['-webkit-transform'] = `scale(${scale})`;
        // this.$refs.frontSide.style['-moz-transform'] = `scale(${scale})`;

      },
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

  .editor-columns-container {
    display: flex;
    /*background: lightblue;*/
  }

  .editor-left-column {
    width: 100%;
    min-height: 300px;
    /*background: lightgreen;*/
    min-width: 100px;
    margin: 0 10px 0;
  }

  .editor-menu {
    /*background: lightgrey;*/
    flex-grow: 0;
    flex-shrink: 0;
    flex-basis: 180px;
    padding: 10px;
    /*margin: 0 0 0 10px;*/
  }

  .discount-config {
    padding-top: 10px;
    padding-left: 10px;
  }

</style>

