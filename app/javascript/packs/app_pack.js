import Vue from 'vue/dist/vue.esm'
import AutomationForm from '../automation_form.vue'
import SubscriptionForm from '../subscription_form'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'

// To get Turbolinks working it helped to put the javascript pack tag in the <head>
// If we need to expand Vue to other parts of the application I suspect it would help
// to keep this structure and load individual containers loaded from this file.
// (with Webpacker code splitting if necessary)

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var automationElement = document.getElementById('automation-editor');
  var newSubscriptionElement = document.getElementById('new-subscription-form');
  var editSubscriptionElement = document.getElementById('edit-subscription-form');


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
          backUrl: automationElement.dataset.backUrl
        }
      },
      template: '<automation-form :id="id" :automation="automation" :aws-sign-endpoint="awsSignEndpoint" :back-url="backUrl"></automation-form>',
      components: {
        'automation-form': AutomationForm
      }
    });
    window.VueAutomation = automationVueApp;
  }

  if (newSubscriptionElement != null) {
    var stripeKeyElement = document.getElementById('stripe-pub-key');
    const vueApp = new Vue(SubscriptionForm(newSubscriptionElement, stripeKeyElement.dataset.stripePubKey));
    window.VueSubscriptionNew = vueApp;
  }

  if (editSubscriptionElement != null) {
    const vueApp = new Vue(SubscriptionForm(editSubscriptionElement));
    window.VueSubscriptionEdit = vueApp;
  }

});
