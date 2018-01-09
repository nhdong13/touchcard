<template>
  <div ref="cardSideCanvas"
       class="card-side-body"
       :style="Object.assign({}, this.backgroundStyle, this.scaleStyle)">

    <div class="card-side-safe-area">
      <discount-element :discount_x.sync="attributes.discount_x"
                        :discount_y.sync="attributes.discount_y"
                        :discount_pct="discount_pct"
                        :discount_exp="discount_exp"
                        v-if="enableDiscount"
      >
      </discount-element>

      <!--<template v-for="object in model.objects">-->
        <!-- element switch -->
        <!-- <concrete-element v-if="object.type === 'concrete'"></concrete-element> -->
        <!-- <another-element v-if="object.type === 'another'"></another-element> -->
      <!--</template>-->
    </div>
  </div>
</template>

<script>

  import DiscountElement from './card_elements/discount_element.vue';

  export default {
    props: {
      attributes: {
        type: Object,
        required: true,
        // validator: function (value) {
        //   return false;
        // }
      },
      enableDiscount: { Boolean },
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
        return { backgroundImage: this.attributes.image ? `url('${this.attributes.image}')` : null }
      }
    },
    // data: function() {
    //   return {
    //   }
    // },
    components:{
      DiscountElement
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

  .card-side-body {
    width: 6.25in;
    height: 4.25in;
    margin: 0 auto;
    transform-origin: left 25%;
    box-shadow: 1px 1px 3px 1px rgba(0.2, 0.2, 0.2, 0.3);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    /*background-color: lightsalmon;*/
    /*border: 1px dashed;*/
  }

  .card-side-safe-area {
    position: absolute;
    width: 5.875in;
    height: 3.875in;
    left: 0.1875in;
    top: 0.1875in;
    background-color: rgba(255, 255, 220, 0.35);
  }

</style>

