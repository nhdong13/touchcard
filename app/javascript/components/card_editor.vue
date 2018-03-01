<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    <div class="editor-columns-container">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
            ref="frontSide"
            class="card-editor-front-side"
            :attributes.sync="front_attributes"
            :enableDiscount="enableFrontDiscount"
            :scaleFactor="cardScaleFactor"
            :discount_pct="discount_pct"
            :discount_exp="discount_exp"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
        <strong>Upload Design</strong>
        <span class="tooltip" data-hover="PNG or JPG image, 1875 by 1275 px">
            <i class="material-icons callout" >help_outline</i>
        </span>
        <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event, FRONT_TYPE)">
        <hr />
        <input id="editor-front-discount" type="checkbox" v-model="enableFrontDiscount">
        <label for="editor-front-discount" class="noselect" >
          <strong>Include Expiring Discount</strong>
          <span class="tooltip" data-hover="Each postcard gets a unique coupon">
            <i class="material-icons callout" >help_outline</i>
          </span>
        </label>

        <div class="discount-config" v-if="enableFrontDiscount">
          <span  v-bind:class="{'tooltip': (discount_pct < 15)}" data-hover="We recommend 15-25% for better conversions">
            <input type="number" min="0" max="100" :value="discount_pct" @input="$emit('update:discount_pct', Number($event.target.value))">
            <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
            <label>% off</label>
            <span v-bind:class="{'alert-color': (discount_pct < 15), 'tooltip': !(discount_pct < 15)}" data-hover="We recommend 15-25% for better conversions">
              <i class="material-icons callout">help_outline</i>
            </span>
          </span>
          <br>
          <span>
            <input type="number" min="1" max="52" :value="discount_exp" @input="$emit('update:discount_exp', Number($event.target.value))">
            weeks expiration
            <span class="tooltip" data-hover="Calculated from estimated delivery date (1 week in US)">
              <i class="material-icons callout" >help_outline</i>
            </span>
          </span>
        </div>
      </div>
    </div>
    <br>
    <hr />
    <h2>Back</h2>
    <div class="editor-columns-container">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
                ref="backSide"
                class="card-editor-back-side"
                :attributes.sync="back_attributes"
                :enableDiscount="enableBackDiscount"
                :scaleFactor="cardScaleFactor"
                :discount_pct="discount_pct"
                :discount_exp="discount_exp"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
        <strong>Upload Design</strong>
        <span class="tooltip" data-hover="PNG or JPG image, 1875 by 1275 px">
            <i class="material-icons callout" >help_outline</i>
        </span>
        <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event, BACK_TYPE)">
        <hr />
        <input id="editor-back-discount" type="checkbox" v-model="enableBackDiscount">
        <label for="editor-back-discount" class="noselect" >
          <strong>Include Expiring Discount</strong>
          <span class="tooltip" data-hover="Each postcard gets a unique coupon">
            <i class="material-icons callout" >help_outline</i>
          </span>
        </label>

        <div class="discount-config" v-if="enableBackDiscount">
          <input type="number" min="0" max="100" :value="discount_pct" @input="$emit('update:discount_pct', Number($event.target.value))">
          <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
          <label>% off</label>
          <span class="tooltip" v-bind:class="{'alert-color': (discount_pct < 15)}" data-hover="We recommend 15-25% for best results">
              <i class="material-icons callout">help_outline</i>
            </span>
          <br>
          <span>
            <input type="number" min="1" max="52" :value="discount_exp" @input="$emit('update:discount_exp', Number($event.target.value))">
            weeks expiration
            <span class="tooltip" data-hover="Calculated from estimated delivery date (1 week in US)">
              <i class="material-icons callout" >help_outline</i>
            </span>
          </span>
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
        type: Number
      },
      discount_exp: {
        type: Number
      },
      front_attributes: {
        type: Object,
        required: true,
      },
      back_attributes: {
        type: Object,
        required: true,
      },
      aws_sign_endpoint: {
        type: String,
        required: true
      }
    },
    components:{
      'card-side': CardSide
    },
    data: function() {
      return {
        enableFrontDiscount: (this.front_attributes.discount_x !== null) && (this.front_attributes.discount_y !== null),
        enableBackDiscount: (this.back_attributes.discount_x !== null) && (this.back_attributes.discount_y !== null),
        cardScaleFactor: 1.0,
        cachedDiscountPct: this.discount_pct || 20,
        cachedDiscountExp: this.discount_exp || 3,
      }
    },
    watch: {
      // For backwards-compatability's sake we  null out card_order.discount_pct
      // and card_order.discount_exp if neither card side has a discount.
      enableFrontDiscount: function() { this.emitDiscountValues(); },
      enableBackDiscount: function() { this.emitDiscountValues(); }
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
    computed: {
      FRONT_TYPE: function() { return 'FRONT_TYPE' },
      BACK_TYPE: function() { return 'BACK_TYPE' }
    },
    methods: {
      emitDiscountValues: function() {
        this.$emit('update:discount_pct', (this.enableFrontDiscount || this.enableBackDiscount) ? this.cachedDiscountPct : null);
        this.$emit('update:discount_exp', (this.enableFrontDiscount|| this.enableBackDiscount) ? this.cachedDiscountExp : null);
      },
      handleResize: function() {
        let leftColumnWidth = this.$refs.editorLeftColumn.offsetWidth;
        let cardWidth = this.$refs.frontSide.$el.offsetWidth // Expecting 6.25in * 96 px = 608
        this.cardScaleFactor = Math.max(0.1, Math.min(1.0, leftColumnWidth / cardWidth));


      },
      // prepareSave: function() {
      //   // // TODO: We should probably have a data structure to monitor parallel uploads + completion
      //   // // And would be nice if uploads happened as soon as added + CardSide has loading icon + completion for not-yet-uploaded images
      //   // let promises = [];
      //   // if (this.front.newImage) {
      //   //   promises.push(this.uploadNewBackground(this.front));
      //   // }
      //   // if (this.back.newImage) {
      //   //   promises.push(this.uploadNewBackground(this.back));
      //   // }
      //   // return Promise.all(promises);
      // },
      updateBackground: function(e, side) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        // TODO: Upload progress (perhaps embedded in dynamic Canvas img/object that doesn't save?)
        // TODO: Block Saving while files are uploading
        this.api.uploadFileToS3(files[0], (error, result) => {
          console.log(error ? error : result);
          if (result) {
            if (side === this.FRONT_TYPE) {
              this.$emit('update:front_attributes', Object.assign(this.front_attributes, {background_url: result}));
            } else if (side === this.BACK_TYPE) {
              this.$emit('update:back_attributes', Object.assign(this.back_attributes, {background_url: result}));
            }
          }
        });
      }
    }
  }
</script>

<style>

  /* Transition delay not quite working */
  /*.editor-left-column {*/
    /*transition: all 1s ease-out;*/
  /*}*/

  /* Show Print Guidelines when hovering near card. This is here so it's decoupled from print rendering */
  .card-side-body {
    clip-path: inset(12px 12px 12px 12px);
  }
  .editor-left-column:not(:hover) {
    filter: drop-shadow(1px 1px 3px rgba(0.2, 0.2, 0.2, 0.3));
  }

  .editor-left-column:hover .card-side-body {
    clip-path: none;
    outline:1px dashed grey;
  }

  .editor-left-column:hover .card-side-safe-area {
    /*background: orange;*/
    /*border: 1px dotted red;*/
    outline:1px dashed orangered;
  }

</style>
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

  .alert-color {
    color: orangered;
  }

</style>

