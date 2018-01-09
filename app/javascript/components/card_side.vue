<template>
  <div ref="cardSideCanvas"
       class="card-side-canvas"
       :style="Object.assign({}, this.backgroundStyle, this.scaleStyle)">

    <discount-element :discount_x.sync="attributes.discount_x"
                      :discount_y.sync="attributes.discount_y"
                      v-if="enableDiscount"
    >
    </discount-element>

    <!--<template v-for="object in model.objects">-->
      <!-- element switch -->
      <!-- <concrete-element v-if="object.type === 'concrete'"></concrete-element> -->
      <!-- <another-element v-if="object.type === 'another'"></another-element> -->
    <!--</template>-->

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

  .card-side-canvas {
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

</style>

