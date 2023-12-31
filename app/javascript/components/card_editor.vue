<template>
  <div>
    <h2 class="custom-h2"><small :class="{'warning-color': showError}" v-if="showError">*</small> {{cardName}}</h2>
    <div :class="['editor-columns-container', {invalid: showError}]">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
                ref="cardSide"
                class="card-editor"
                :isBack="isBack"
                :attributes.sync="attributes"
                :scaleFactor="cardScaleFactor"
                :discount_pct="discount_pct"
                :discount_exp="discount_exp_string"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
        <strong class="mb-3">Upload Design</strong>
        <!--<span class="tooltip" data-hover="PNG or JPG image, 1875 by 1275 px">-->
        <!--<i class="material-icons callout" >help_outline</i>-->
        <!--</span>-->
        <br>
        <div class="f-s-080 grey">
          <ul>
            <li>PNG or JPG (required)</li>
            <li>1875 by 1275 pixels (recommended)</li>
            <li><a href="/images/front-side-guide.jpg" target="_blank">guidelines</a>, <a href="http://touchcard.co/templates/" target="_blank">templates</a></li>
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
        <div class="upload-img-section">
          <label v-bind:for="'upload-image-' + _uid" class="upload-img-btn">Choose File</label>
          <span class="noselect upload-img-name"> {{ imageName | truncateImageName(25) }}</span>
          <input v-bind:id="'upload-image-' + _uid" class="upload-img-input" type="file" accept="image/png,image/jpeg" @change="updateBackground($event)">
        </div>
        <hr />
        <input v-bind:id="'discount-toggle-' + _uid" type="checkbox" v-model="attributes.showsDiscount">
        <label class="noselect" >
          <strong>Include Expiring Discount</strong>
          <i class="material-icons callout" v-b-tooltip.hover title="Each postcard gets a unique coupon">help_outline</i>
        </label>
        <div class="discount-config" v-if="attributes.showsDiscount">
          <span :id="'discount-input-'+cardName">
            <input type="number" min="0" max="100" :value="discount_pct" @input="$emit('update:discount_pct', Number($event.target.value))">
            <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
            <label>% off</label>
            <i :class="['material-icons', 'callout', {'warning-color': (discount_pct < 15)}]" v-b-tooltip.hover title="We recommend 15-25%">help_outline</i>
          </span>
          <br>
          <span>
            <input type="number" min="1" max="52" :value="discount_exp" @input="$emit('update:discount_exp', Number($event.target.value))">
            weeks expiration
            <i class="material-icons callout" v-b-tooltip.hover title="Calculated from estimated delivery date (1 week in US)">help_outline</i>
          </span>
          <b-tooltip :show="discount_pct < 15" :target="'discount-input-'+cardName" placement="top" triggers="none">
            We recommend 15-25% for better conversions
          </b-tooltip>
        </div>
      </div>
    </div>
    <br>
  </div>
</template>

<script>
  import { Api } from '../api';
  import CardSide from './card_side.vue';
  import { CardAttributes } from './card_attributes';
  import { DEFAULT_DISCOUNT_PERCENTAGE, DEFAULT_WEEK_BEFORE_DISCOUNT_EXPIRE } from '../config';

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
        type: Number,
        default: DEFAULT_DISCOUNT_PERCENTAGE
      },
      discount_exp: {
        type: Number,
        default: DEFAULT_WEEK_BEFORE_DISCOUNT_EXPIRE
      },
      aws_sign_endpoint: {
        type: String,
        required: true
      },
      checkingError: {
        type: Boolean,
        require: true,
      },
      errorPresent: {
        type: Boolean,
        require: true,
      },
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
        showError: false,
        cardName: this.isBack ? "Back" : "Front",
        imageName: "No file chosen"
      }
    },
    watch: {
      // For backwards-compatability's sake we  null out card_order.discount_pct
      // and card_order.discount_exp if neither card side has a discount.
      attributes: function(val) {
        console.log('attributes changed ' + val);
      },

      checkingError: function(val) {
        this.checkIfErrorExist(true);
      },

      discount_exp: function() {
        if (this.attributes.showsDiscount) this.checkIfErrorExist();
      },

      discount_pct: function() {
        if (this.attributes.showsDiscount) this.checkIfErrorExist();
      }
    },
    mounted: function() {

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
    computed: {
      discount_exp_string: function() {
        let exp = new Date();
        exp.setDate(exp.getUTCDate() + (7 * this.discount_exp + 7));
        return `${exp.getMonth()+1}/${exp.getDate()}/${exp.getFullYear()}`;
      },
    },
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
        this.imageName = files[0].name;

        if (!files.length)
          return;

        if ((files[0].size) > 1024 * 1024 * 10) {
          alert('Please limit your file to 10 MB or less.');
          e.target.value = '';
          return;
        }

        if (!(files[0].type.match('image/png')) && !(files[0].type.match('image/jpeg'))) {
          alert('Please upload a PNG or JPG image.');
          e.target.value = '';
          return;
        }

        this.isUploading = true;

        // TODO: Block Saving while files are uploading
        this.api.uploadFileToS3(files[0], (error, result) => {
          if (result) {
            this.alertNonOptimalImageDimensions(result);
            this.$emit('update:attributes', Object.assign(this.attributes, {background_url: result}));
            this.isUploading = false;
            this.checkIfErrorExist();
          }
        });
      },

      checkIfErrorExist(doShowError = false) {
        let flag = false;
        let { background_url, showsDiscount } = this.attributes;
        if (!background_url) flag = true;
        if (showsDiscount && (this.discount_pct == 0 || this.discount_exp == 0)) flag = true;
        this.showError = doShowError && flag;
        this.$emit('update:errorPresent', flag);
      }
    },

    filters: {
      truncateImageName(data, num) {
        if (data.length <= num) return data;
        let truncateText = data.substring(0, 11) + '...' + data.substring(data.length - 11);
        return truncateText;
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
    width: fit-content;
  }

  .warning-color {
    color: orangered;
  }

  .invalid {
    border: 1px solid red;
  }

  .custom-h2 {
    font-size: 1.5em;
    font-weight: 700;
  }
  
  .upload-img-section {
    min-width: 246px;
    width: max-content;
  }

  .upload-img-input {
    /* opacity: 0; */
    display: none;
  }
  
  .upload-img-btn {
    background-color: rgb(240, 240, 240);
    font-size: 13px;
    padding: 3px 6px;
    border: 0.2px solid lightslategray;
    border-radius: 1px;
    margin: 0px;
  }

  .upload-img-btn:hover {
    background-color: rgb(233, 233, 233);
  }

  .upload-img-name {
    text-overflow: ellipsis;
  }
</style>

