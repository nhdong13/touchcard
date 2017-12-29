<template>
  <div ref="cardSideCanvas"
       class="card-side-canvas"
       :style="Object.assign({}, this.backgroundStyle, this.cardScaleStyle)">
    <card-element
        ref="discountElement"
        class="discount"
        :style="discountStyle"
        :parent="true"
    >
    </card-element>
    <!--<vue-draggable-resizable :w="170" :h="100" :parent="true">-->
    <!--<p>draggable</p>-->
    <!--</vue-draggable-resizable>-->

  </div>
</template>

<script>

  import CardElement from './card_element.vue'
  import CardSide from './card_side.vue';


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
      'card-element': CardElement
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

  .discount {
    position: absolute;
    top: 30%;
    left: 30%;
    width: 28%;
    height: 25%;
    text-align: center;
    font-family: 'Montserrat';
    background-color: mediumpurple;
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

