<template>
    <base-element
            ref="discountRect"
            class="discount"
            :w="160"
            :h="95"
            :resizable="false"
            :parent="true"
            :x="safe_discount_x"
            :y="safe_discount_y"
            @dragstop="emitDiscountCoords"

    >
        <div class="percent">{{Math.abs(discount_pct)}}% OFF</div>
        <div class="code">DIS-CNT-COD</div>
        <div class="expiration">{{dateToday}}</div>
    </base-element>
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
      },
      discount_pct: {
        required: true,
        type: Number
      },
      discount_exp: {
        required: true,
        type: Number
      }
    },
    computed: {
      dateToday: function() {
        let today= new Date();
        return `${today.getDate()}/${today.getMonth() + 1}/${today.getFullYear()}`;
      },
      safe_discount_x: function() {
        return (typeof this.discount_x === 'number') ? this.discount_x : 215;
      },
      safe_discount_y: function() {
        return (typeof this.discount_y === 'number') ? this.discount_y : 154;
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
    // // First 'Mounted' happens before first 'Computed'
    // mounted: function() {
    //   // Make sure the intial centering is reflected in parent component
    //   // console.log('mounted')
    //   // this.emitDiscountCoords(this.discountLeft, this.discountTop);
    // },
    methods: {
      emitDiscountCoords: function(left, top) {
        // Convert Discount to % and Emit
        this.$emit('update:discount_x', this.$refs['discountRect'].left );
        this.$emit('update:discount_y', this.$refs['discountRect'].top );
      }
    }
  }
</script>

<style>
    .discount.dragging, .discount:hover {
        background: repeating-linear-gradient(
                45deg,
                rgba(200, 200, 200, 0.3),
                rgba(200, 200, 200, 0.3) 5px,
                rgba(150, 150, 150, 0.3) 5px,
                rgba(150, 150, 150, 0.3) 10px );
    }

</style>
<style scoped>

    .discount {
        position: absolute;
        text-align: center;
        width: 160px;
        height: 95px;
        font-family: 'Montserrat';
        user-select: none;
    }


    .percent {
        font-size: 0.30in;
        font-weight: 800;
        margin: 0.06in 0 0;
    }

    .code {
        font-size: 0.17in;
    }

    .expiration {
        margin-top: 0.11in;
        font-size: 0.09in;
    }


</style>
