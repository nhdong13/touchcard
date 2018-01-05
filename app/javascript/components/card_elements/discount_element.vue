<template>
  <base-element
      class="discount"
      :w="170"
      :h="100"
      :resizable="false"
      :parent="true"
      :x="discountLeft"
      :y="discountTop"
      @dragstop="emitDiscountCoords"

  ></base-element>
</template>

<script>
  import BaseElement from './base_element.vue';

  export default {
    name: 'discount_element',
    extends: BaseElement,
    props: {
      discount_x: {
        required: true,
        validator: function (val) {
          return val === null || typeof val === 'number'
        }
      },
      discount_y: {
        required: true,
        validator: function (val) {
          return val === null || typeof val === 'number'
        }
      }
    },
    computed: {
      // Convert Discount from %. Might be better to just migrate?
      discountLeft: function() {
        console.log("computed");
        return this.discount_x * 625 / 100;
      },
      discountTop: function() {
        return this.discount_y * 425 / 100;
      },
    },
    mounted: function() {
      this.emitDiscountCoords(this.discountLeft, this.discountTop);
    },
    methods: {
      emitDiscountCoords: function(left, top) {
        // Convert Discount to % and Emit
        this.$emit('update:discount_x', left / 625 );
        this.$emit('update:discount_y', top / 425 );
      }

    }
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
