<template>
  <discount-element v-if="type === 'discount'"></discount-element>

  <!-- <ANOTHER-KIND-OF-ELEMENT  v-if="type === 'discount'"></discount-element> -->
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
