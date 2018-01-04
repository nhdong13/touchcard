<template>
  <div ref="cardSideCanvas"
       class="card-side-canvas"
       :style="Object.assign({}, this.backgroundStyle, this.cardScaleStyle)">

    <!--<template v-for="object in model.objects">-->
      <!-- element switch -->
      <!-- <concrete-element v-if="object.type === 'concrete'"></concrete-element> -->
      <!-- <another-element v-if="object.type === 'another'"></another-element> -->
    <!--</template>-->

    <!-- OR -->

    <!--<card-element v-for="object in model.objects" :key="object.id" type="object.type"></card-element>-->

    <card-side-element
        :type="enableDiscount ? 'discount' : null"
    ></card-side-element>

    <!--<card-element-->
        <!--ref="discountElement"-->
        <!--class="discount"-->
        <!--:style="discountStyle"-->
        <!--:parent="true"-->
        <!--:w="170"-->
        <!--:h="100"-->
        <!--:resizable="false"-->
    <!--&gt;-->
    <!--</card-element>-->

  </div>
</template>

<script>

  import CardSideElement from './card_side_element.vue'

  export default {
    props: {
      backgroundUrl: { String, default: '' },
      enableDiscount: { Boolean },
      scaleFactor: { Number, default: 1.0 },
    },
    // mounted: function() {
    //   window.card_side = this;
    // },
    watch: {
      backgroundUrl: function(val) {
        this.backgroundStyle.backgroundImage = `url('${val}')`;
      },
      enableDiscount: function(val) {
        this.discountStyle.display = val ? 'inline': 'none';
      },
      scaleFactor: function(val) {
        this.cardScaleStyle.transform = this.scaleFactor ? `scale(${this.scaleFactor})`: null;
      }
    },
    data: function() {
      return {
        discountStyle: {
          display: 'none',
        },
        backgroundStyle: {
            backgroundImage: this.backgroundUrl ? `url('${this.backgroundUrl}')` : null,
        },
        // IGNORE ON SERIALIZATION
        cardScaleStyle: {
          transform: `scale(${this.scaleFactor})`
        }
      }
    },
    components:{
      'card-side-element': CardSideElement
    },
    // methods: {
    //   updateBackground: function() {
    //   }
    // }
  }
</script>
<style scoped>

  :focus {
    outline: 1px dotted black;
  }

  /* Required for Coupon */
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

