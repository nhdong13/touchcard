<template>
    <div
        class="card-side-canvas"
        :style="backgroundStyle"
    >
      <div
          class="discount"
          :style="discountStyle"
      >
      </div>

    </div>


</template>

<script>

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
          backgroundColor: 'purple'
        },
        backgroundStyle: {
          backgroundImage: this.backgroundUrl ? `url('${this.backgroundUrl}')` : null, // `url('${this.backgroundUrl}')`
        }
      }
    }
    // methods: {
    //   updateBackground: function() {
    //   },
    // }
  }
</script>

<style scoped>

  /* Required for Coupon */
  @import url('https://fonts.googleapis.com/css?family=Montserrat');

  p {
    font-size: 2em;
    text-align: center;
  }

  /*.canvas-container-wrapper {*/
  /*}*/


  /*#card-side-aspect-padder > div {*/
    /*position: absolute;*/
    /*top: 0; bottom: 0; left: 0; right: 0;*/
  /*}*/


  .discount {
    position: absolute;
    top: 30%;
    left: 30%;
    width: 28%;
    height: 25%;
    text-align: center;
    font-family: 'Montserrat';
  }


  .card-side-canvas {
    padding-bottom: 68%;

    /*background-image: url('https://touchcard-data-dev.s3.amazonaws.com/uploads/7113021b-7ca8-4b35-b634-f2feaaad8696/__card_01.jpg');*/
    /*background-size: 96% 95%;*/
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;

    /*background: lightyellow;*/


  /*position: relative;*/
    /*top: 0;*/
    /*bottom: 0;*/
    /*left: 0;*/
    /*right: 0;*/

    /*width: 6.25in;*/
    /*height: 4.25in;*/

    /*width: 100%;*/
    /*height: 100%;*/
    /*height: 425px;*/

    /*padding-bottom: 68%;*/

    /*display: flex;*/
    /*padding: 10px;*/
    /*!*margin: 20px;*!*/
    /*background: #fff0da;*/
  }




</style>

