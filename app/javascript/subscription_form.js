/* global mdc */
/* global StripeCheckout */

export default function(element) {
  return {
    el: element,
    // props: {
    //   stripe_pub_key: {
    //     type: String,
    //     required: true,
    //   },
    // },
    data: function() {
      return {
        slider: null,
        quantity: 0,
        stripeHandler: StripeCheckout.configure({
          key: 'pk_test_b2E1nYrhI3XF6qpyNFIxHEb8', // TODO: Get key dynamically
          locale: 'auto',
          name: 'Touchcard',
          description: 'Postcard Subscription',
          image: '/touchcard-logo-white-spaced-700x700.jpg',
          zipCode: true,
          panelLabel: 'Subscribe',
          // allowRememberMe: false,
          // label: 'BUY IT NOW',
          // custom
          token: function (token) {
            document.querySelector('input#stripeToken').value = token.id;
            document.querySelector('#checkout-form').submit();
          }
        })
      }
    },
    computed: {
      price: function() {
        return this.quantity * 0.99;
      }
    },
    mounted: function() {
      this.slider  = new mdc.slider.MDCSlider(this.$refs.quantitySlider);
      this.slider.listen('MDCSlider:input', () => {
        this.updateQuantity();
      });
      this.updateQuantity();
    },
    beforeDestroy: function() {
      this.stripeHandler.close();
      delete this.stripeHandler;
    },
    methods: {
      updateQuantity: function() {
        let index = this.slider.value;
        this.quantity = this.$refs.quantitySelect.options[index].text;
      },
      checkoutSubmit: function(event) {
        if (event) event.preventDefault();
        this.stripeHandler.open({
          amount: this.price * 100
        });

      }
    }
  }
}
