<template>
<!-- NOTE:
  4.25 inches x 6.25 inches => 408px x 600px
-->
<div class="flip-card">
  <div class="flip-card-inner">
    <div class="flip-card-front">
      <img width="60" hieght="40" v-if="frontImage">
      <div class="center" v-else>
        <strong>NO PREVIEW AVAILABLE</strong>
      </div>
    </div>
    <div class="flip-card-back">
      <img width="60" hieght="40" v-if="backImage">
      <div class="center" v-else>
        <strong>NO PREVIEW AVAILABLE</strong>
      </div>
    </div>
  </div>
</div>
</template>
<script>
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
    }
  }
</script>
<style lang="scss" scoped>
.flip-card {
  width: 60px;
  height: 40px;
  border: 1px solid #f1f1f1;
  perspective: 1000px;
}

.flip-card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  text-align: center;
  transition: transform 0.8s;
  transform-style: preserve-3d;
}

.flip-card:hover .flip-card-inner {
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
</style>