import Vue from 'vue/dist/vue.esm'
import AutomationForm from '../automation_form'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'


// To get Turbolinks working it helped to put the javascript pack tag in the <head>
// If we need to expand Vue to other parts of the application I suspect it would help
// to keep this structure and load individual containers loaded from this file.
// (with Webpacker code splitting if necessary)

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('automation-editor');

  if (element != null) {

    const vueApp = new Vue({
      el: element,
      data: function() {
        let tmp_automation = JSON.parse(element.dataset.automation);
        tmp_automation.card_side_front_attributes = JSON.parse(element.dataset.cardSideFrontAttributes);
        tmp_automation.card_side_back_attributes = JSON.parse(element.dataset.cardSideBackAttributes);
        return {
          id: element.dataset.id,
          automation: tmp_automation,
          awsSignEndpoint: element.dataset.awsSignEndpoint
        }
      },
      template: '<AutomationForm :id="id" :automation="automation" :aws-sign-endpoint="awsSignEndpoint" ></AutomationForm>',
      components: { AutomationForm }
    })
    window.Vue = vueApp;
  }
});
