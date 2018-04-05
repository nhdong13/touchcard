<template>
  <div class="card-side-body--wrapper" :style="this.scaleStyle">
    <div class="card-side-body"
         v-bind:class="{'front-side-body': !isBack, 'back-side-body': isBack}"
         :style="Object.assign({}, this.backgroundStyle)">

      <div class="card-side-safe-area">
        <discount-element :discount_x.sync="attributes.discount_x"
                          :discount_y.sync="attributes.discount_y"
                          :discount_pct="discount_pct"
                          :discount_exp="discount_exp"
                          v-if="attributes.showsDiscount"
        >
        </discount-element>
        <!--<template v-for="object in model.objects">-->
        <!-- element switch -->
        <!-- <concrete-element v-if="object.type === 'concrete'"></concrete-element> -->
        <!-- <another-element v-if="object.type === 'another'"></another-element> -->
        <!--</template>-->
      </div>
      <address-overlay-element v-if="isBack"></address-overlay-element>

    </div>
  </div>
</template>
<script>

  import DiscountElement from './card_elements/discount_element.vue';
  import AddressOverlayElement from './card_elements/address_overlay_element.vue';

  export default {
    props: {
      attributes: {
        type: Object,
        required: true,
        // validator: function (value) {
        //   return false;
        // }
      },
      isBack: {
        type: Boolean,
        required: true,
      },
      scaleFactor: { Number, default: 1.0 },
      discount_pct: { Number },
      discount_exp: { Number },
    },
    computed: {
      scaleStyle: function () {
        // TODO: We need to include all the browser-specific scale transforms
        return (this.scaleFactor ? {transform: `scale(${this.scaleFactor})` }: null);
      },
      backgroundStyle: function () {
        return { backgroundImage: this.attributes.background_url ? `url('${this.attributes.background_url}')` : null }
      }
    },
    // data: function() {
    //   return {
    //   }
    // },
    components:{
      DiscountElement, AddressOverlayElement
    },
  }
</script>
<style scoped>

  :focus {
    outline: 1px dotted black;
  }

  /* Required for Discount */
  @import url('https://fonts.googleapis.com/css?family=Montserrat');

  p {
    font-size: 2em;
    text-align: center;
  }

  .card-side-body--wrapper {
    width: 6.25in;
    height: 4.25in;
    transform-origin: left 25%;
  }

  .card-side-body {
    width: inherit;
    height: inherit;
    margin: 0 auto;
    background-color: white;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    clip-path: inset(12px 12px 12px 12px);
    /*pointer-events: auto;*/
  }

  .card-side-safe-area {
    /* TODO: These safe area guide positions don't end up properly aligned on the final card */
    /* The dimensions are right, but the result isn't. Improperly centered? Use pixels intead of inches? */
    position: absolute;
    width: 5.875in;
    height: 3.875in;
    left: 0.1875in;
    top: 0.1875in;
  }

</style>

