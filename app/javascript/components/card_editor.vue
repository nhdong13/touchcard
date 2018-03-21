<template>
  <div class="editor-columns-container">
    <div ref="editorLeftColumn" class="editor-left-column">
      <card-side
              ref="cardSide"
              class="card-editor"
              :isBack="isBack"
              :attributes.sync="attributes"
              :scaleFactor="cardScaleFactor"
              :discount_pct="discount_pct"
              :discount_exp="discount_exp"
      >
      </card-side>
    </div>
    <div class="editor-menu editor-right-column">
      <strong>Upload Design</strong>
      <!--<span class="tooltip" data-hover="PNG or JPG image, 1875 by 1275 px">-->
      <!--<i class="material-icons callout" >help_outline</i>-->
      <!--</span>-->
      <br>
      <div class="f-s-080 grey">
        <ul>
          <li>PNG or JPG (required)</li>
          <li>1875 by 1275 pixels (recommended)</li>
          <li><a href="/images/front-side-guide.jpg" target="_blank">guidelines</a>, <a href="http://touchcard.co/templates/" target="_blank">templates</a></span></li>
        </ul>
      </div>
      <div role="progressbar" v-if="isUploading" class="mdc-linear-progress mdc-linear-progress--indeterminate">
        <div class="mdc-linear-progress__buffering-dots"></div>
        <div class="mdc-linear-progress__buffer"></div>
        <div class="mdc-linear-progress__bar mdc-linear-progress__primary-bar">
          <span class="mdc-linear-progress__bar-inner"></span>
        </div>
        <div class="mdc-linear-progress__bar mdc-linear-progress__secondary-bar">
          <span class="mdc-linear-progress__bar-inner"></span>
        </div>
      </div>
      <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event)">
      <br>
      <hr />
      <input v-bind:id="'discount-toggle-' + _uid" type="checkbox" v-model="attributes.showsDiscount">
      <label v-bind:for="'discount-toggle-' + _uid" class="noselect" >
        <strong>Include Expiring Discount</strong>
        <span class="tooltip" data-hover="Each postcard gets a unique coupon">
            <i class="material-icons callout" >help_outline</i>
          </span>
      </label>
      <div class="discount-config" v-if="attributes.showsDiscount">
          <span  v-bind:class="{'tooltip': (discount_pct < 15)}" data-hover="We recommend 15-25% for better conversions">
            <input type="number" min="0" max="100" :value="discount_pct" @input="$emit('update:discount_pct', Number($event.target.value))">
            <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
            <label>% off</label>
            <span v-bind:class="{'warning-color': (discount_pct < 15), 'tooltip': !(discount_pct < 15)}" data-hover="We recommend 15-25%">
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
</template>

<script>
  import { Api } from '../api';
  import CardSide from './card_side.vue';
  import { CardAttributes } from './card_attributes';

  export default {
    props: {
      json: {
        type: Object,
        required: true,
      },
      isBack: {
        type: Boolean,
        required: true,
      },
      discount_pct: {
        type: Number
      },
      discount_exp: {
        type: Number
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
        // This component's CardAttributes should be the source of truth. Any modifications should be emitted
        // up to here, but no further. It's left up to the containing form to pull data up before saving.
        attributes: new CardAttributes(this.json),
        cardScaleFactor: 1.0,
        isUploading: false,
      }
    },
    watch: {
      // For backwards-compatability's sake we  null out card_order.discount_pct
      // and card_order.discount_exp if neither card side has a discount.
      attributes: function(val) {
        console.log('attributes changed ' + val);
      }
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
      window.card_editor = null;
      window.removeEventListener('resize', this.handleResize)
    },
    // computed: {
    // },
    methods: {
      alertNonOptimalImageDimensions: function(url) {
        var offscreenImage = new Image();
        offscreenImage.src = url; //this.front_attributes.background_url;
        offscreenImage.onload = () => {
          if (offscreenImage.width !== 1875 || offscreenImage.height != 1275){
            alert("Your uploaded image is not 1875 by 1275 pixels. \nPlease make sure your postcard doesn't look stretched or pixelated");
            errors.push('Image must be 1875px by 1275px');
            // ShopifyApp.flashNotice("Your uploaded image is not 1875 by 1275 pixels. \nPlease make sure your postcard doesn't look stretched or pixelated.");
          }
        }
      },
      handleResize: function() {
        let leftColumnWidth = this.$refs.editorLeftColumn.offsetWidth;
        let cardWidth = this.$refs.cardSide.$el.offsetWidth; // Expecting 6.25in * 96 px = 608
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
      updateBackground: function(e) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;

        if ((files[0].size) > 1024 * 1024 * 10) {
          alert('Please limit your file to 10 MB or less.');
          e.target.value = '';
          return;
        }

        if (!(files[0].type.match('image/'))) {
          alert('Please upload a PNG or JPG image.');
          e.target.value = '';
          return;
        }

        this.isUploading = true;

        // TODO: Block Saving while files are uploading
        this.api.uploadFileToS3(files[0], (error, result) => {
          console.log(error ? error : result);
          if (result) {
            this.alertNonOptimalImageDimensions(result);

              this.$emit('update:attributes', Object.assign(this.attributes, {background_url: result}));
              this.isUploading = false;

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
  /*.editor-left-column:not(:hover) {*/
    /*filter: drop-shadow(1px 1px 3px rgba(0.2, 0.2, 0.2, 0.3));*/
  /*}*/

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

  .warning-color {
    color: orangered;
  }

</style>

