<template>
  <div class="card-editor-container">
    <h2>Front</h2>
    <div class="editor-columns-container">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
            ref="frontSide"
            :attributes.sync="front_attributes"
            :enableDiscount="enableFrontDiscount"
            :scaleFactor="cardScaleFactor"
            :discount_pct="discount_pct"
            :discount_exp="discount_exp"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
        <strong>Upload Background</strong>
        <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event, FRONT_TYPE)">
        <hr />
        <input type="checkbox" v-model="enableFrontDiscount"><strong>Include Expiring Discount</strong>
        <div class="discount-config" v-if="enableFrontDiscount">
          <span>
            <input type="number" min="0" max="100" :value="Math.abs(discount_pct)" @input="$emit('update:discount_pct', Number(-$event.target.value))">
            <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
            % off
          </span><br>
          <span>
            <input type="number" min="1" max="52" :value="discount_exp" @input="$emit('update:discount_exp', Number($event.target.value))">
            weeks expiration
          </span>
        </div>
      </div>
    </div>
    <hr>
    <h2>Back</h2>
    <div class="editor-columns-container">
      <div ref="editorLeftColumn" class="editor-left-column">
        <card-side
                ref="frontSide"
                :attributes.sync="back_attributes"
                :enableDiscount="enableBackDiscount"
                :scaleFactor="cardScaleFactor"
                :discount_pct="discount_pct"
                :discount_exp="discount_exp"
        >
        </card-side>
      </div>
      <div class="editor-menu editor-right-column">
        <strong>Upload Background</strong>
        <input type="file" accept="image/png,image/jpeg"  @change="updateBackground($event, BACK_TYPE)">
        <hr />
        <input type="checkbox" v-model="enableBackDiscount"><strong>Include Expiring Discount</strong>
        <div class="discount-config" v-if="enableBackDiscount">
          <span>
            <input type="number" min="0" max="100" :value="Math.abs(discount_pct)" @input="$emit('update:discount_pct', Number(-$event.target.value))">
            <!--<input type="number" min="0" max="100" :value="automation.discount_pct" @input="$emit('update:automation', Object.assign(automation, {discount_pct: Number($event.target.value)}))">-->
            % off
          </span><br>
          <span>
            <input type="number" min="1" max="52" :value="discount_exp" @input="$emit('update:discount_exp', Number($event.target.value))">
            weeks expiration
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
        enableFrontDiscount: this.discount_pct && this.discount_exp,
        enableBackDiscount: this.discount_pct && this.discount_exp,
        cardScaleFactor: 1.0,
        cachedDiscountPct: this.discount_pct || 20,
        cachedDiscountExp: this.discount_exp || 3,
      }
    },
    watch: {
      // TODO: For backwards-compatability's sake we would like to null out card_order.discount_pct and
      // card_order.discount_exp if neither card side has a discount, but that may just complicate
      // things without being absolutely necessary
      enableFrontDiscount: function(val) {
        this.$emit('update:discount_pct', (val || this.enableBackDiscount) ? this.cachedDiscountPct : null);
        this.$emit('update:discount_exp', (val || this.enableBackDiscount) ? this.cachedDiscountExp : null);
      },
      enableBackDiscount: function(val) {
        this.$emit('update:discount_pct', (val || this.enableFrontDiscount) ? this.cachedDiscountPct : null);
        this.$emit('update:discount_exp', (val || this.enableFrontDiscount) ? this.cachedDiscountExp : null);
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
      window.removeEventListener('resize', this.handleResize)
    },
    computed: {
      FRONT_TYPE: function() { return 'FRONT_TYPE' },
      BACK_TYPE: function() { return 'BACK_TYPE' }
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
              this.$emit('update:front_attributes', Object.assign(this.front_attributes, {image: result}));
            } else if (side === this.BACK_TYPE) {
              this.$emit('update:back_attributes', Object.assign(this.back_attributes, {image: result}));
            }
          }
        });
      }
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

