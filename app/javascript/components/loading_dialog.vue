<template>
  <modal
    name="loading-modal"
    class="loading-modal"
    :clickToClose="false"
    width="50"
    height="50"
    styles="position: absolute;top: 50%;left: 50%;background: transparent;box-shadow: none;"
  >
    <img
      :src="require('../../assets/images/loading.gif')"
      width="50"
      height="50"
    />
  </modal>
</template>
<script>
export default {
  name: "LoadingDialog",
  props: {
    modalDisplay: {
      type: Boolean,
      required: true,
    },
  },
  watch: {
    modalDisplay: function (val) {
      if (val) {
        this.$modal.show("loading-modal");
      } else {
        this.$modal.hide("loading-modal");
      }
    },
  },
};
</script>
