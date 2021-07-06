<template>
<!-- NOTE:
  4.25 inches x 6.25 inches => 408px x 600px
-->
<div class="flip-card">
  <div class="flip-card-inner">
    <div class="flip-card-front">
      <img width="100" hieght="60" :src="frontImage" v-if="frontImage">
      <div class="center" v-else>
        <strong>NO PREVIEW AVAILABLE</strong>
      </div>
    </div>
    <div class="flip-card-back">
      <img width="100" hieght="60" :src="backImage" v-if="backImage">
      <div class="center" v-else>
        <strong>NO PREVIEW AVAILABLE</strong>
      </div>
    </div>
  </div>
  <div class="flip-button" v-if="!isImagesNotAvailable">
    <font-awesome-icon icon="reply" class="fa-flip-vertical fa-2x mt-20"/>
  </div>
</div>
</template>
<script>
  import { isEmpty } from 'lodash'
  export default {
    name: "PreviewImage",
    props: {
      frontImage: {
        type: String,
        default: null
      },
      backImage: {
        type: String,
        default: null
      }
    },

    data: function() {
      return {
        isFlipped: false
      }
    },

    mounted() {
      console.log(this.frontImage)
      console.log(this.backImage)
      const _this = this
      $(".flip-button").on("click", function() {
        _this.isFlipped = !_this.isFlipped
        $(this).siblings(".flip-card .flip-card-inner").toggleClass("flipped", _this.isFlipped)
      })
    },

    methods: {
      isImagesNotAvailable: function() {
        return isEmpty(this.frontImage) && isEmpty(this.backImage)
      }
    }
  }
</script>
<style lang="scss" scoped>
.flip-card {
  width: 100px;
  height: 60px;
  border: 1px solid #f1f1f1;
  perspective: 1000px;
  position: relative;
}

.flip-card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  text-align: center;
  transition: transform 0.8s;
  transform-style: preserve-3d;
  img {
    max-width: 100%;
    max-height: 100%;
  }
}

.flip-card .flip-card-inner.flipped {
  transform: rotateY(180deg);
}

.flip-card-front, .flip-card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  -webkit-backface-visibility: hidden; /* Safari */
  backface-visibility: hidden;
  background-color: white;
  color: Gray;
}

.flip-card-back {
  transform: rotateY(180deg);
}

.center {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center
}

.flip-button {
  position: absolute;
  top: 75%;
  left: 85%;
  background: rgba(255, 255, 255, 0.3);
  width: 50px;
  height: 50px;
  border-radius: 50%;
}

.mt-20 {
  margin-top: 20%;
}
</style>