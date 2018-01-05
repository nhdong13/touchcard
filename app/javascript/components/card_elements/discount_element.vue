<template>
  <base-element
      ref="discountRect"
      class="discount"
      :w="170"
      :h="100"
      :resizable="false"
      :parent="true"
      :x="discount_x || 215"
      :y="discount_y || 154"
      @dragstop="emitDiscountCoords"

  ></base-element>
</template>

<script>
  import BaseElement from './base_element.vue';

  // TODO NOW: Make sure that initial enabling goes to center, and that it's appropriately emitted to parent.

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
    beforeDestroy: function() {
      this.$emit('update:discount_x', null);
      this.$emit('update:discount_y', null);
    },
    // Convert from inches or keep pixels?
    // computed: {
    //   discountLeft: function() {
    //     console.log('computed')
    //     return (this.discount_x === null) ? 215 : this.discount_x;
    //   },
    //   discountTop: function() {
    //     return (this.discount_y === null) ? 154 : this.discount_y;
    //   },
    // },
    // First 'Mounted' happens before first 'Computed'
    mounted: function() {
      // Make sure the intial centering is reflected in parent component
      console.log('mounted')
      this.emitDiscountCoords(this.discountLeft, this.discountTop);
    },
    methods: {
      emitDiscountCoords: function(left, top) {
        // Convert Discount to % and Emit
        this.$emit('update:discount_x', this.$refs['discountRect'].left );
        this.$emit('update:discount_y', this.$refs['discountRect'].top );
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
