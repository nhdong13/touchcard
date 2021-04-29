<template>
  <div class="automation-form">
    <a :href="backUrl"  class="mdc-button mdc-button--stroked">Cancel</a>
    <button v-on:click="requestSave" class="mdc-button mdc-button--raised">Save</button>
    <hr>
    <!-- div v-cloak></div -->
    <h3>{{automation.type}}</h3>
    <div class="automation-section">
      <strong>Type</strong>
      <input type="radio" id="automation" value="automation" v-model="automation.campaign_type" v-on:click="setBudgetType">
      <label for="automation">Automation</label>
      <input type="radio" id="one_off" value="one_off" v-model="automation.campaign_type" v-on:click="setBudgetType">
      <label for="one_off">One-off</label>
    </div>

    <div class="automation-section">
      <strong>Budget</strong>
      <span v-if="automation.campaign_type =='automation'">
        <input type="radio" id="non_set_budget" value="non_set" v-model="budget_type">
        <label for="non_set_budget">Non set</label>
      </span>
      <span v-if="automation.campaign_type =='automation'">
        <input type="radio" id="monthly_budget" value="monthly" v-model="budget_type">
        <label for="monthly_budget">Monthly</label>
      </span>
      <input type="radio" id="lifetime_budget" value="lifetime" v-model="budget_type">
      <label for="lifetime_budget">Lifetime</label>
      <div class="filter-config nested-toggle" v-if="setLimitToKens">
        <span>
          Limit: <input type="numer" id="budget_limit" v-model="automation.budget_update"> credits
        </span>
      </div>
    </div>

    <div class="automation-section" v-if="automation.campaign_type =='one_off'">
      <strong>Send at</strong>
      <datepicker v-model="sendDate"></datepicker>
    </div>

    <div v-if="automation.campaign_type =='automation'" class="automation-section">
      <strong>Send card <input type="number" min="0" max="52" v-model="automation.send_delay"> weeks after purchase</strong>
    </div>
    <!--
      <br>
      <input id="automation-international-checkbox" type="checkbox" v-model="automation.international" />
      <label for="automation-international-checkbox" class="noselect"><strong>Send outside USA</strong></label>
      <div class="attention-note nested-toggle" v-if="automation.international">
            <span>
              <em>Note: International postcards cost two credits.</em>
            </span>
      </div>
      <br v-if="!automation.international">
    -->

    <div class="automation-section">
      <input id="automation-filter-checkbox" type="checkbox" v-model="enableFiltering">
      <label for="automation-filter-checkbox" class="noselect"><strong>Filter by Order Size</strong></label>
      <div class="filter-config nested-toggle" v-if="enableFiltering">
        <span>
          Minimum $: <input type="number" min="1" max="9999" v-model="automation.filters_attributes[automation.filters_attributes.length-1].filter_data.minimum">
        </span>
      </div>
    </div>
    <hr>

    <h2>Front</h2>
    <card-editor
            ref="frontEditor"
            :isBack="false"
            :json="automation.front_json"
            :discount_pct.sync="automation.discount_pct"
            :discount_exp.sync="automation.discount_exp"
            :aws_sign_endpoint="awsSignEndpoint"
    ></card-editor>
    <br>
    <hr />
    <h2>Back</h2>
    <card-editor
            ref="backEditor"
            :isBack="true"
            :json="automation.back_json"
            :discount_pct.sync="automation.discount_pct"
            :discount_exp.sync="automation.discount_exp"
            :aws_sign_endpoint="awsSignEndpoint"
    ></card-editor>
    <br>
  </div>
</template>

<script>
  /* global Turbolinks */
  import axios from 'axios'
  import CardEditor from './components/card_editor.vue'
  import Datepicker from 'vuejs-datepicker';


  export default {
    props: {
      id: {
        required: false
      },
      automation: {
        type: Object,
        required: true
      },
      awsSignEndpoint: {
        type: String,
        required: true
      },
      backUrl: {
        type: String,
        required: true
      }
    },
    data: function() {
      return {
        enableFiltering: (this.automation.filters_attributes.length > 0),
        sendDate: "",
        budget_type: this.automation.budget_type,
        willShowBudgetType: true,
      }
    },

    computed: {
      setLimitToKens: function(){
        let willSet = true;
        if(this.budget_type == "non_set"){
          willSet = false
        }
        return willSet
      }
    },

    watch: {
      enableFiltering: function(enable) {
        console.log('enableFiltering: ' + enable);
        if (enable) {
          const default_min_max = {minimum: 10, maximum: 99999};
          if (this.automation.filters_attributes.length > 0) {
            let last_index = this.automation.filters_attributes.length-1;
            this.automation.filters_attributes[last_index].filter_data = default_min_max;
          } else {
            this.automation.filters_attributes = [{ filter_data: default_min_max}];
          }
        } else {
          if (this.automation.filters_attributes.length > 0) {
            let last_index = this.automation.filters_attributes.length-1;
            let last_filter_id = this.automation.filters_attributes[last_index].id;
            this.automation.filters_attributes[last_index] = {'id': last_filter_id, _destroy: true};
          }
        }
      }
    },
    components: {
      // 'card-editor': () => ({
      //   // https://vuejs.org/v2/guide/components.html#Async-Components
      //   component: import('./components/card_editor.vue')
      //   // loading: LoadingComp, error: ErrorComp, delay: 200, timeout: 3000
      // })
      CardEditor,
      'card-editor': CardEditor,
      Datepicker
    },
    beforeMount: function() {
      // Set defaults in case these props are passed as 'null'
      this.automation.discount_pct = this.automation.discount_pct || 20;
      this.automation.discount_exp = this.automation.discount_exp || 3;
    },
    methods: {
      setBudgetType: function(event){
        let campaign_type = event.target.value;
        if(campaign_type == "one_off"){
          this.budget_type = "lifetime"
          this.willShowBudgetType = false
        } else {
          this.budget_type = this.automation.budget_type
          this.willShowBudgetType = true
        }
      },

      requestSave: function() {

        // TODO: Wait for uploads to complete in CardEditor
        // this.$refs.cardEditor.prepareSave();

        // Get card side data for saving
        let frontAttrs = this.$refs.frontEditor.$data.attributes;
        let backAttrs = this.$refs.backEditor.$data.attributes;

        this.automation.front_json = frontAttrs;
        this.automation.back_json = backAttrs;

        // Null out discount_pct and discount_exp for backwards-compatability (might not be essential)
        // Using `.showsDiscount` assumes card_editor.vue has created card_attributes objects from json
        if (!frontAttrs.showsDiscount && !backAttrs.showsDiscount ) {
          this.automation.discount_pct = null;
          this.automation.discount_exp = null;
        }

        this.automation.budget_type = this.budget_type

        this.postOrPutForm();

        // // Ask the CardEditor to finish its uploads, serialization, etc
        // this.$refs.cardEditor.requestSave()
        //   .then((results) => {
        //     console.log(results)
        //     this.postOrPutForm()
        //   }).catch(function (err) {
        //   console.log(err)
        // })
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
            ShopifyApp.flashError(error.request.responseText);
          });
        } else {
          // Create a new automation (POST)
          axios.post('/automations.json', { card_order: this.automation})
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
            ShopifyApp.flashError(error.request.responseText);
          });
        }
      }
    }
  }
</script>

<style lang="scss" scoped>
  [v-cloak] {
    display: none;
  }
  .automation-section{
    margin: 16px 0
  }
  .nested-toggle {
    padding-top: 10px;
    padding-left: 10px;
  }

  .automation-form{
    .vdp-datepicker{
      display: inline-block;
    }
  }

</style>
