<template>
  <div ref="cardSideCanvas" class="card-side-canvas" :style="backgroundStyle">
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
  import VueDraggableResizable from 'vue-draggable-resizable';
  import CardSide from './card_side.vue';


  export default {
    props: {
      backgroundUrl: { String, default: '' },
      enableDiscount: { Boolean }
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
    },
    data: function() {
      return {
        discountStyle: {
          display: 'none',
        }
        backgroundStyle: {
          backgroundImage: this.backgroundUrl ? `url('${this.backgroundUrl}')` : null, // `url('${this.backgroundUrl}')`
        }
      }
    },
    components:{
      'card-element': VueDraggableResizable
    },
    // methods: {
    //   updateBackground: function() {
    //   }
    // }
  }
</script>
<style scoped>


  :focus {
    outline: 5px dotted black;
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
    transform-origin: left;

    /*box-shadow: 5px 5px 10px #555;*/

    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: lightsalmon;

  }

</style>

