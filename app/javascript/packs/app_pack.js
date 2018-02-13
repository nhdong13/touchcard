import Vue from 'vue/dist/vue.esm'
import AutomationForm from '../automation_form'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'

import SubscriptionForm from '../subscription_form.js'

// To get Turbolinks working it helped to put the javascript pack tag in the <head>
// If we need to expand Vue to other parts of the application I suspect it would help
// to keep this structure and load individual containers loaded from this file.
// (with Webpacker code splitting if necessary)

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var automationElement = document.getElementById('automation-editor');
  var subscriptionElement = document.getElementById('subscription-form');


  if (automationElement != null) {

    const automationVueApp = new Vue({
      el: automationElement,
      data: function() {
        let tmp_automation = JSON.parse(automationElement.dataset.automation);
        // Discard all filters except last one, then pass as single entry in array
        tmp_automation.filters_attributes = JSON.parse(automationElement.dataset.filters);
        return {
          id: automationElement.dataset.id,
          automation: tmp_automation,
          awsSignEndpoint: automationElement.dataset.awsSignEndpoint,
        }
      },
      template: '<automation-form :id="id" :automation="automation" :aws-sign-endpoint="awsSignEndpoint"></automation-form>',
      components: {
        'automation-form': AutomationForm
      }
    });
    window.VueAutomation = automationVueApp;
  }

  if (subscriptionElement != null) {

    // Object.assign(SubscriptionForm, {element: subscriptionElement})

    const subscriptionVueApp = new Vue({
      el: subscriptionElement,
      props: {
        // suggestedQuantity: {
        //   required: false
        // }
      },
      data: function() {
        return {
          slider: null
        }
      },
      mounted: function() {
        this.slider  = new mdc.slider.MDCSlider(this.$refs.quantitySlider);
        this.updateQuantity();
        this.slider.listen('MDCSlider:input', () => {
          this.updateQuantity();
        });
      },
      methods: {
        updateQuantity: function() {
          console.log(this.slider.value);

          let index = this.slider.value;
          this.$refs.quantitySelect.selectedIndex = index;
          let selectedQuantityText = this.$refs.quantitySelect.options[index].text;
          this.$refs.quantityDisplay.innerHTML = selectedQuantityText;

          let price = (selectedQuantityText * 0.99).toFixed(2);
          this.$refs.checkoutPriceDisplay.innerHTML = '$' + price;
          window.checkoutPriceDisplay = price;
        },
      }
    });
    window.VueSubscription = subscriptionVueApp;
  }
});
