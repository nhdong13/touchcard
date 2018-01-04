<template>
  <discount-element v-if="type === 'discount'"></discount-element>

  <!-- list all elements - acts like a switch to select components -->
  <!-- <another-element v-if="type === 'another'"></another-element> -->

</template>

<script>
  import DiscountElement from './card_elements/discount_element.vue';

  export default {
    props: {
      type: null
    },
    components:{
      DiscountElement
    },
  }
</script>
