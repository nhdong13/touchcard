/* global Turbolinks */
import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter);
import axios from 'axios'
import * as api from './api'

export default function loadAutomationEditor (element) {

  let id = element.dataset.id;
  let automation = JSON.parse(element.dataset.automation);
  let awsSignEndpoint = element.dataset.awsSignEndpoint;
  automation.card_side_front_attributes = JSON.parse(element.dataset.cardSideFrontAttributes);
  automation.card_side_back_attributes = JSON.parse(element.dataset.cardSideBackAttributes);

  return new Vue({
    el: element,
    data: function() {
      return {
        id: id,
        automation: automation,
        awsSignEndpoint: awsSignEndpoint,
        enableDiscount: true
      };
    },
    components: {
      'card-editor': () => ({
        // https://vuejs.org/v2/guide/components.html#Async-Components
        component: import('./components/card_editor')
        // loading: LoadingComp, error: ErrorComp, delay: 200, timeout: 3000
      })
    },
    methods: {
      requestSave: function() {
        // Ask the CardEditor to finish its uploads and serialization (attributes are written back via :props.sync)
        this.$refs.cardEditor.requestSave()
          .then((results) => {
            console.log(results)
            this.postOrPutForm()
          }).catch(function (err) {
            console.log(err)
          })
      },
      postOrPutForm: function() {

        if (this.id) {
          // Edit existing automation (PUT)
          let target = `/automations/${this.id}.json`;
          axios.put(target, { card_order: this.automation })
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
        } else {
          // Create a new automation (POST)
          axios.post('/automations.json', { card_order: this.automation})
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
              console.log(error);
            });
        }
      }
    }
  });
}