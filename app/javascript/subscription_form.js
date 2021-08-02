/* global mdc */
/* global StripeCheckout */

// Todo: Use Stripe Checkout via NPM
import { isEmpty } from 'lodash'

export default function(element ,stripePubKey = '') {
  return {
    el: element,
    data: function() {
      return {
        slider: null,
        quantity: 0,
        customerEmail: null,
        stripeHandler: StripeCheckout.configure({
          key: stripePubKey,
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
            // TODO: Clean up w/ Refs / models
            document.querySelector('input#stripeToken').value = token.id;
            document.querySelector('#checkout-form').submit();
          }
        })
      }
    },
    computed: {
      price: function() {
        let pricePerCard = parseFloat(document.getElementById('price-per-card').value);
        return this.quantity * pricePerCard;
      }
    },
    mounted: function() {
      this.slider  = new mdc.slider.MDCSlider(this.$refs.quantitySlider);
      this.slider.listen('MDCSlider:input', () => {
        this.updateQuantity();
      });
      this.updateQuantity();
      if(!isEmpty(document.getElementById('customer-email'))) {
        this.customerEmail = document.getElementById('customer-email').value
      }
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
          amount: this.price * 100,
          email: this.customerEmail,
        });

      }
    }
  }
}
