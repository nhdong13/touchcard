import Vue from 'vue/dist/vue.esm'
import AutomationForm from '../automation_form.vue'
import SubscriptionForm from '../subscription_form'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);

import axios from 'axios'
import store from './store'

import vueCountryRegionSelect from 'vue-country-region-select'
Vue.use(vueCountryRegionSelect)

import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'
import { MdDivider, MdChips, MdSubheader, MdButton,
  MdDialog, MdSwitch
} from 'vue-material/dist/components'
Vue.use(MdDivider)
Vue.use(MdChips)
Vue.use(MdSubheader)
Vue.use(MdButton)
Vue.use(MdDialog)
Vue.use(MdSwitch)

import campaignDashboard from '../components/campaigns/index'

import Paginate from 'vuejs-paginate'
Vue.component('paginate', Paginate)

import { library } from '@fortawesome/fontawesome-svg-core'
import { 
  faCaretDown, faCaretUp, faLongArrowAltDown, faCalendarAlt,
  faCaretRight, faCaretLeft, faReply, faTrashAlt, faChevronDown, faFileCsv
} from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
library.add(faCaretDown, faCaretUp, faLongArrowAltDown, faCalendarAlt,
  faCaretRight, faCaretLeft, faReply, faTrashAlt, faChevronDown, faFileCsv)
Vue.component('font-awesome-icon', FontAwesomeIcon)

import VueScreen from 'vue-screen';
Vue.use(VueScreen);

import VModal from 'vue-js-modal';
Vue.use(VModal, { componentName: 'modal'});

import { BootstrapVue, IconsPlugin } from 'bootstrap-vue';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
Vue.use(BootstrapVue);
// Optionally install the BootstrapVue icon components plugin
Vue.use(IconsPlugin);

import moment from 'moment';
Vue.prototype.moment = moment;

import PostcardDashboard from '../components/dashboard/dashboard_postcard_table'

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
  var postcardDashboardElement = document.getElementById('postcard-table');

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
          backUrl: automationElement.dataset.backUrl,
          isUserHasPaymentMethod: automationElement.dataset.isUserHasPaymentMethod == "true",
          currentShop: JSON.parse(automationElement.dataset.currentShop),
          shared: store
        }
      },
      template: '<automation-form :id="id" :automation="automation" :return-address="returnAddress" :aws-sign-endpoint="awsSignEndpoint" :back-url="backUrl" :is-user-has-payment-method="isUserHasPaymentMethod" :shared="shared" :currentShop="currentShop" ></automation-form>',
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
        return {
          campaigns: JSON.parse(campaignDashboardElement.dataset.campaigns),
          searchParams: JSON.parse(campaignDashboardElement.dataset.searchParams),
          totalPages: parseInt(campaignDashboardElement.dataset.totalPages),
          shared: store
        }
      },
      template: '<campaign-dashboard :campaigns="campaigns" :totalPages="totalPages" :shared="shared" :searchParams="searchParams" />',
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

  if (postcardDashboardElement != null) {
    const vueApp = new Vue({
      el: postcardDashboardElement,
      data: function() {
        let dataset = postcardDashboardElement.dataset;
        return {
          postcards: JSON.parse(dataset.postcards),
          totalPages: parseInt(dataset.totalPages),
          searchParams: JSON.parse(dataset.searchParams)
        }
      },
      template: '<postcard-table :postcards="postcards" :totalPages="totalPages" :searchParams="searchParams"></postcard-table>',
      components: {
        'postcard-table': PostcardDashboard
      }
    });
    window.VueDashboardPostcard = vueApp;
  }

});
