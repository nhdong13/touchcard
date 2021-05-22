import Vue from 'vue/dist/vue.esm'
import AutomationForm from '../automation_form.vue'
import SubscriptionForm from '../subscription_form'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'
import vueCountryRegionSelect from 'vue-country-region-select'
Vue.use(vueCountryRegionSelect)
import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'

import campaignDashboard from '../components/campaigns/index'

import Paginate from 'vuejs-paginate'
Vue.component('paginate', Paginate)

import { library } from '@fortawesome/fontawesome-svg-core'
import { faCaretDown, faCaretUp, faLongArrowAltDown, faCalendarAlt } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
library.add(faCaretDown, faCaretUp, faLongArrowAltDown, faCalendarAlt)
Vue.component('font-awesome-icon', FontAwesomeIcon)

// To get Turbolinks working it helped to put the javascript pack tag in the <head>
// If we need to expand Vue to other parts of the application I suspect it would help
// to keep this structure and load individual containers loaded from this file.
// (with Webpacker code splitting if necessary)

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var automationElement = document.getElementById('automation-editor');
  var campaignDashboardElement = document.getElementById('campaigns-dashboard');
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
          returnAddress: JSON.parse(automationElement.dataset.returnAddress),
          awsSignEndpoint: automationElement.dataset.awsSignEndpoint,
          backUrl: automationElement.dataset.backUrl
        }
      },
      template: '<automation-form :id="id" :automation="automation" :return-address="returnAddress" :aws-sign-endpoint="awsSignEndpoint" :back-url="backUrl"></automation-form>',
      components: {
        'automation-form': AutomationForm
      }
    });
    window.VueAutomation = automationVueApp;
  }

  if (campaignDashboardElement != null) {
    const campaignDashboardVueApp = new Vue({
      el: campaignDashboardElement,
      data: function() {
        let tmp_campaigns = JSON.parse(campaignDashboardElement.dataset.campaigns);
        return {
          campaigns: tmp_campaigns,
          totalPages: parseInt(campaignDashboardElement.dataset.totalPages),
          statuses: JSON.parse(campaignDashboardElement.dataset.statuses),
          campaignTypes: JSON.parse(campaignDashboardElement.dataset.campaignTypes)
        }
      },
      template: '<campaign-dashboard :campaigns="campaigns" :totalPages="totalPages" :campaignStatuses="statuses" :campaignTypes="campaignTypes"></campaign-dashboard>',
      components: {
        campaignDashboard
      }
    });
    window.VueCampaignDashboard = campaignDashboardVueApp;
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
