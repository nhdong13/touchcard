<template>
  <base-element
      class="discount"
      :w="170"
      :h="100"
      :resizable="false"
      :parent="true"
  ></base-element>
</template>

<script>
  import BaseElement from './base_element.vue';

  export default {
    name: 'discount_element',
    extends: BaseElement,
  }
</script>

<style scoped>

  .discount {
    position: absolute;
    text-align: center;
    font-family: 'Montserrat';
    background-color: orange;
  }

</style>
