<template>
  <div class="automation_form">
    <h1>New Campaign</h1>
    <hr/>
    <h2>Campaign Settings</h2>
    <div class="automation-section">
      <strong>Campaign name </strong>
      <input id="campaign_name" v-model="automation.campaign_name">
      <span class="error campaign-name-error">This field is required.</span>
    </div>

    <div class="automation-section">
      <strong>Type</strong>
      <span v-if="automation.campaign_status == 'draft' || automation.campaign_type == 'automation'">
        <input type="radio" id="automation" value="automation" v-model="campaign_type" v-on:click="setBudgetType">
        <label for="automation">Automation</label>
      </span>
      <span v-if="automation.campaign_status == 'draft' || automation.campaign_type == 'one_off'">
        <input type="radio" id="one_off" value="one_off" v-model="campaign_type" v-on:click="setBudgetType">
        <label for="one_off">One-off</label>
      </span>
    </div>

    <div class="automation-section" v-if="campaign_type =='automation'">
      <strong>Monthly budget</strong>
      <span>
        <input type="numer" id="budget_limit" v-model="budget"> credits
      </span>
    </div>

    <div class="automation-section" v-if="campaign_type =='one_off'">
      <div>
        <strong>Campaign schedule</strong>
      </div>
      <div>
        <div class="filter-config nested-toggle">
          <div class="datepicker-with-icon">
            <span style="width: 80px">Start date:</span>
            <datepicker
              v-model="automation.send_date_start"
              :disabled-dates="disabledDates"
              :open-date="new Date()"
              name="send_date_start"
              ref="sendDateStart"
              @selected="changeSendDateEnd"
              :disabled="isStartDateEqualCurrentDate"
            ></datepicker>
            <div class="icon-calendar" v-on:click="openSendDateStartDatePicker">
              <font-awesome-icon icon="calendar-alt"/>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="automation-section" v-if="campaign_type =='one_off'">
      <div>
        <input id="daily-schedule-checkbox" type="checkbox" v-model="willCheckDailySendingSchedule">
        <label for="daily-schedule-checkbox" class="noselect"><strong>Daily schedule and limits</strong></label>
      </div>
      <div class="filter-config nested-toggle" v-if="willShowDailySendingSchedule">
        <span>Limit per day:</span>
        <input type="numer" id="budget_limit" v-model="automation.limit_cards_per_day"> postcards
      </div>
    </div>

    <div class="automation-section" v-else>
      <strong>Campaign schedules</strong>
      <div class="flex-center">
        <div class="campaign-section nested-toggle">
          <div class="datepicker-with-icon">
            <span style="width: 80px">Start date:</span>
            <datepicker
              v-model="automation.send_date_start"
              :disabled-dates="disabledDates"
              :open-date="new Date()"
              name="send_date_start"
              ref="sendDateStart"
              @selected="changeSendDateEnd"
              :disabled="isStartDateEqualCurrentDate"
            ></datepicker>
            <div class="icon-calendar" v-on:click="openSendDateStartDatePicker">
              <font-awesome-icon icon="calendar-alt"/>
            </div>
          </div>
        </div>
        <div class="campaign-section nested-toggle" v-if="!automation.send_continuously">
          <div class="datepicker-with-icon">
            <span style="width: 80px">End date<small :class="{error: errors.endDate}" v-if="errors.endDate">*</small>:</span>
            <div :class="['datepicker-with-icon', {invalid: errors.endDate}]">
              <datepicker
                v-model="automation.send_date_end"
                :disabled-dates="disabledEndDates"
                name="sendDateEnd"
                ref="sendDateEnd"
                :disabled="automation.send_continuously"
              ></datepicker>
              <div class="icon-calendar" v-on:click="openSendDateEndDatePicker">
                <font-awesome-icon icon="calendar-alt"/>
              </div>
            </div>
          </div>
        </div>
        <div class="send-continuously-option pt-ongoing-checkbox">
          <input id="send-continuously" type="checkbox" v-model="automation.send_continuously"/>
          <label for="send-continuously" class="noselect">- Ongoing</label>
        </div>
      </div>
    </div>

    <div :class="[errors.returnAddress ? 'invalid' : '', 'automation-section']">
      <label for="return-address-checkbox" class="noselect"><strong>Add Return Address</strong></label>
      <button @click="enableAddReturnAddress= !enableAddReturnAddress">Edit</button>
      <div class="nested-toggle return-address" v-if="enableAddReturnAddress">
        <div class="row">
          <div class="col-8">
            <div class="row center-items">
              <div class="col-2 address-label"></div>
              <div class="col-6">
                <span class="error d-none return-address-general-error">
                  <em>Please fill in all return address required fields.</em>
                </span>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>Name<span class='error'>*</span></h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <input type="text" name="from[name]" id="from_name" data-lpignore="true" v-model="returnAddress.name" @change="checkDataIsValid">
                </div>
                <span class="error d-none"><em>This field is required.</em></span>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>Address line 1<span class='error'>*</span></h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <input type="text" name="from[address_line1]" id="from_address_line1" v-model="returnAddress.address_line1" @change="checkDataIsValid">
                </div>
                <span class="error d-none"><em>This field is required.</em></span>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>Address line 2</h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <input type="text" name="from[address_line2]" id="from_address_line2" v-model="returnAddress.address_line2">
                </div>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>City<span class='error'>*</span></h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <input type="text" name="from[city]" id="from_city" v-model="returnAddress.city" @change="checkDataIsValid">
                </div>
                <span class="error d-none"><em>This field is required.</em></span>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>State<span class='error'>*</span></h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <region-select id="from_state" v-model="onSelectState" :region="onSelectState" :blackList="['AS','DC', 'FM', 'GU', 'MH', 'MP', 'PW', 'RP', 'VL', 'AA', 'AE', 'AP', 'VI', 'PR']"/>
                </div>
                <span class="error d-none"><em>This field is required.</em></span>
              </div>
            </div>
            <div class="row center-items">
              <div class="col-2 address-label">
                <h4>Zip<span class='error'>*</span></h4>
              </div>
              <div class="col-6">
                <div class="row">
                  <input type="text" name="from[zip]" id="from_zip" v-model="returnAddress.zip" @change="checkDataIsValid">
                </div>
                <span class="error d-none"><em>This field is required.</em></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <input id="automation-filter-checkbox" type="checkbox" v-model="enableFiltering">
    <label for="automation-filter-checkbox" class="noselect"><strong>Enable Filter</strong></label>
    <button @click="downloadCSV"> CSV </button>
    <div class="filter-config nested-toggle row" v-if="enableFiltering">
      <div id="accepted-section">
        <div class="filter-section-title">Include these customers</div>
        <button type="button" class="add-more-filter-btn" id="add-accepted-filter" @click="addFilter('accepted')">Add Filter</button>
        <filter-option :filter="filter" v-for="(filter, index) in acceptedFilters" :key="index" @filterChange="filterChange" @filterRemove="filterRemove" collection="accepted" :index="index" />
      </div>
      <div id="removed-section">
        <div class="filter-section-title">Exclude these customers</div>
        <button type="button" class="add-more-filter-btn" id="add-removed-filter" @click="addFilter">Add Filter</button>
        <filter-option :filter="filter" v-for="(filter, index) in removedFilters" :key="index" @filterChange="filterChange" @filterRemove="filterRemove" collection="removed" :index="index" />
      </div>
      <div v-if="campaign_type =='automation'" class="automation-section">
        <strong>Send card <input type="number" min="0" max="52" v-model="automation.send_delay"> weeks after purchase</strong>
      </div>
    </div>
    <!-- <hr />
    <h2>Add Contact</h2>
    <button>Shopify</button> -->
    <hr />
    <h2>Front<small :class="{error: errors.uploadedFrontDesign}" v-if="errors.uploadedFrontDesign">*</small></h2>
    <div :class="{ invalid: errors.uploadedFrontDesign }">
      <card-editor
              ref="frontEditor"
              :isBack="false"
              :json="automation.front_json"
              :discount_pct.sync="automation.discount_pct"
              :discount_exp.sync="automation.discount_exp"
              :aws_sign_endpoint="awsSignEndpoint"
      ></card-editor>
    </div>
    <br>
    <hr />
    <h2>Back<small :class="{error: errors.uploadedBackDesign}" v-if="errors.uploadedBackDesign">*</small></h2>
    <div :class="{ invalid: errors.uploadedBackDesign }">
      <card-editor
              ref="backEditor"
              :isBack="true"
              :json="automation.back_json"
              :discount_pct.sync="automation.discount_pct"
              :discount_exp.sync="automation.discount_exp"
              :aws_sign_endpoint="awsSignEndpoint"
      ></card-editor>
    </div>
    <br>
    <div class="text-right">
      <md-button class="cancel-btn text-white" v-on:click="cancel" >Cancel</md-button>
      <md-button class="review-and-continue-btn text-white" v-on:click="saveAndReview">Review and continue</md-button>
    </div>
    <div>
      <cancel-campaign-dialog
        :md-active.sync="isCancel"
        title="Cancel?"
        content="This action can not be undone and you will lose all progress. Are you sure to continue?"
        confirm-text="Cancel anyway"
        cancel-text="No, go back"
        @onCancel="onCancel"
        @onConfirm="onConfirm"
        v-if="isEditExistCampaign"
      />
    </div>
  </div>
</template>

<script>
  /* global Turbolinks */
  import axios from 'axios'
  import CardEditor from './components/card_editor.vue'
  import FilterOption from './components/filter_option.vue'
  import Datepicker from 'vuejs-datepicker';
  import $ from 'jquery'
  import { isEmpty } from 'lodash'
  import CancelCampaignDialog from './components/cancel_campaign_dialog.vue'
  window.$ = $

  export default {
    props: {
      id: {
        required: false
      },
      automation: {
        type: Object,
        required: true
      },
      returnAddress: {
        type: Object
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
    created() {
      this.isEditExistCampaign = !this.isCampaignNew()
      if(isEmpty(this.automation.send_date_start)) {
        this.automation.send_date_start = new Date()
      } else {
        const today = new Date()
        const startDate = new Date(this.automation.send_date_start)
        if(startDate.getTime() <= today.getTime()) {
          this.isStartDateEqualCurrentDate = true
        } else {
          this.disabledDates.from = new Date(startDate - 8640000)
          today.setDate(today.getDate() - 1)
          this.disabledDates.to = today
        }
      }
      
    },
    mounted: function() {
      if(this.automation.campaign_status == "draft") {
        window.setInterval(() => {
          this.saveAutomation()
        }, 1000)
      } else {
        this.saveAutomation()
      }
    },
    data: function() {
      return {
        onSelectState: this.returnAddress.state,
        enableFiltering: (this.automation.filters_attributes.length > 0),
        enableAddReturnAddress: false,
        acceptedFilters: [],
        removedFilters: [],
        sendDate: "",
        budget_type: this.automation.budget_type ? this.automation.budget_type : "non_set",
        budget: this.automation.budget_type == "monthly" ? this.automation.budget : null,
        willShowBudgetType: true,
        campaign_type: this.automation.campaign_type ? this.automation.campaign_type : "automation",
        willShowDailySendingSchedule: false,
        disabledDates: {
          to: new Date(Date.now() - 8640000)
        },
        isCancel: false,
        isStartDateEqualCurrentDate: false,
        saved_automation: {}, // Use with autosave, play as backup when user don't want to change campaign any more
        saved_filters: [],
        isEditExistCampaign: true,
        errors: {
          endDate: false,
          uploadedFrontDesign: false,
          uploadedBackDesign: false,
          returnAddress: false
        }
      }
    },

    computed: {
      disabledEndDates: function(){
        let startDate = this.automation.send_date_start || new Date()
        return {to: new Date(new Date(startDate) - 8640000)}
      },

      willCheckDailySendingSchedule: {
        get: function(){
          let willShow = false;
          if(this.automation.campaign_type == "one_off" && this.automation.limit_cards_per_day > 0){
            willShow = true;
            this.willShowDailySendingSchedule = true
          }
          return willShow;
        },
        set: function(value){
          if (value) {
            this.willShowDailySendingSchedule = true
          } else {
            this.automation.limit_cards_per_day = 0
            this.willShowDailySendingSchedule = false
          }
        }
      }
    },

    watch: {
      enableFiltering: function(enable) {
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
      },

      onSelectState: function() {
        let state = $("#from_state").val()
        this.returnAddress.state = state
        if(this.automation.international){
          if(!state){
            $("#from_state").parents(".col-6").find("span").show()
          } else{
            $("#from_state").parents(".col-6").find("span").hide()
          }
        }
      },

      budget: function(value) {
        if(isEmpty(this.budget)) {
          this.budget_type = "non_set"
          this.automation.budget_update = 0
        } else {
          this.budget_type = "monthly"
          this.automation.budget_update = value  
        }
      }
    },

    components: {
      // 'card-editor': () => ({
      //   // https://vuejs.org/v2/guide/components.html#Async-Components
      //   component: import('./components/card_editor.vue')
      //   // loading: LoadingComp, error: ErrorComp, delay: 200, timeout: 3000
      // })
      FilterOption,
      CardEditor,
      'card-editor': CardEditor,
      Datepicker,
      CancelCampaignDialog
    },

    beforeMount: function() {
      // Set defaults in case these props are passed as 'null'
      this.automation.discount_pct = this.automation.discount_pct || 20;
      this.automation.discount_exp = this.automation.discount_exp || 3;
      // console.log(this.automation);
      let last_index = this.automation.filters_attributes.length-1;
      let filters = this.automation.filters_attributes[last_index].filter_data;
      this.convertRawFilters(filters);
      this.automation.send_date_end = this.automation.send_date_end || new Date()
      this.automation.send_date_start = this.automation.send_date_start || new Date()
    },

    methods: {
      checkDataIsValid: function({ type, target }) {
        if(this.automation.international){
          if(!target.value){
            $(target).parents(".col-6").find("span").show()
          } else{
            $(target).parents(".col-6").find("span").hide()
          }
        }
      },

      changeSendDateEnd: function (){
        this.automation.send_date_end = ""
        this.openSendDateEndDatePicker();
      },

      openSendDateEndDatePicker: function(){
        this.$refs.sendDateEnd.showCalendar()
        this.$refs.sendDateEnd.$el.querySelector('input').focus()
      },

      openSendDateStartDatePicker: function(){
        this.$refs.sendDateStart.showCalendar()
        this.$refs.sendDateStart.$el.querySelector('input').focus()
      },

      setBudgetType: function(event){
        let campaign_type = event.target.value;
        if(campaign_type == "one_off"){
          this.willShowBudgetType = false
        } else {
          this.budget_type = this.automation.budget_type
          this.willShowBudgetType = true
        }
      },

      checkNameCampaignIsInvalid: function() {
        if(!this.automation.campaign_name) {
          $(".campaign-name-error").show()
          return true;
        } else {
          $(".campaign-name-error").hide()
          return false;
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

        // Using `.showsDiscount` assumes card_editor.vue has created card_attributes objects from json
        if (!frontAttrs.showsDiscount && !backAttrs.showsDiscount ) {
          // Fallback to default
          this.automation.discount_pct = 20;
          this.automation.discount_exp = 2;
        }

        this.automation.budget_type = this.budget_type
        this.automation.campaign_type = this.campaign_type

        if (this.checkNameCampaignIsInvalid()) return;

        this.postOrPutForm();
      },
      postOrPutForm: function() {
        if (this.id) {
          // Edit existing automation (PUT)
          let target = `/automations/${this.id}.json`;
          this.automation.return_address_attributes = this.returnAddress;
          if (this.enableFiltering) this.collectFilters();
          axios.put(target, { card_order: this.automation})
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
      },
      addFilter(list) {
        let defaultValue = {selectedFilter: "", selectedCondition: 0, value: null};
        this.removeEmptyFilter();
        list == "accepted" ? this.acceptedFilters.push(defaultValue) : this.removedFilters.push(defaultValue);
      },
      filterChange(filter, collection, index) {
        if(filter.selectedFilter == "shipping_country" && filter.selectedCondition == "from" && collection == "accepted") {
          this.automation.international = true
        }
        collection == "accepted" ? this.acceptedFilters[index] = filter : this.removedFilters[index] = filter;
      },
      filterRemove(filter, collection, index) {
        if(filter.selectedFilter == "shipping_country" && filter.selectedCondition == "from" && collection == "accepted") {
          this.automation.international = false
        }
        collection == "accepted" ? this.acceptedFilters.splice(index, 1) : this.removedFilters.splice(index, 1);
      },
      removeEmptyFilter() {
        $(".filter-value").each(function() {
          if ($(this).val() == "") {
            $(this).parent().remove();
          }
        });
      },
      convertRawFilters(rawValue) {
        ["accepted", "removed"].forEach(section => {
          Object.keys(rawValue[section]).forEach(value => {
            let defaultValue = {selectedFilter: value, selectedCondition: rawValue[section][value].condition, value: rawValue[section][value].value};
            section == "accepted" ? this.acceptedFilters.push(defaultValue) : this.removedFilters.push(defaultValue);
          });
        });
      },
      collectFilters() {
        let collectedFilters = this.convertFiltersToParams();
        let last_index = this.automation.filters_attributes.length-1;
        this.automation.filters_attributes[last_index].filter_data = collectedFilters;
        return this.automation.filters_attributes[last_index].filter_data;
      },
      convertFiltersToParams() {
        let res = {};
        // Prevent error
        // Cannot read property '[object Array]' of undefined
        const filters = [this.acceptedFilters, this.removedFilters].filter(Boolean)
        filters.forEach((collection, index) => {
          let tmp = this.generateFilterToObject(collection);
          index == 0 ? res["accepted"] = tmp : res["removed"] = tmp;
        })
        return res;
      },
      generateFilterToObject(list) {
        let tmp = {};
        list.forEach((item) => {
          if (item["value"] == null) return;
          tmp[item["selectedFilter"]] = {condition: item["selectedCondition"], value: item["value"]};
        });
        return tmp;
      },
      downloadCSV() {
        let url = `/targeting/get.csv`;
        let body = this.convertFiltersToParams();
        axios.post(url, body).then(function(response) {
          const url = window.URL.createObjectURL(new Blob([response.data]))
          const link = document.createElement('a')
          link.href = url
          link.setAttribute('download', 'customers.csv')
          document.body.appendChild(link)
          link.click()
        }).catch(function (error) {
          console.log(error)
        });
      },
      onCancel: function() {
        this.isCancel = false
      },
      onConfirm: function() {
        Turbolinks.clearCache()
        Turbolinks.visit('/automations', {flush: true, cacheRequest: false});
      },
      saveAutomation: function() {
        if (this.enableFiltering && this.automation.campaign_status == "draft") this.collectFilters();
        // This will minimize the overhead of clone the automation
        if(this.isTwoJsonEqual(this.saved_automation, this.automation) && this.isEditExistCampaign == true) {
          return
        }

        // Get card side data for saving
        let frontAttrs = this.$refs.frontEditor.$data.attributes;
        let backAttrs = this.$refs.backEditor.$data.attributes;

        this.automation.front_json = frontAttrs;
        this.automation.back_json = backAttrs;

        // Using `.showsDiscount` assumes card_editor.vue has created card_attributes objects from json
        if (!frontAttrs.showsDiscount && !backAttrs.showsDiscount ) {
          // Fallback to default
          this.automation.discount_pct = 20;
          this.automation.discount_exp = 2;
        }

        this.automation.budget_type = this.budget_type
        this.automation.campaign_type = this.campaign_type
        this.automation.return_address_attributes = this.returnAddress;
        if(this.enableFiltering) this.collectFilters()
        // TODO: Must somehow make sure automation is JSON safe
        this.saved_automation = JSON.parse(JSON.stringify(this.automation))

        if(this.automation.campaign_status == "draft") {
          axios.put(`/automations/${this.id}.json`, { card_order: this.automation})
            .then(function(response) {
            }).catch(function (error) {
              console.log(error)
          });
        }
      },
      isTwoJsonEqual: function(a, b) {
        return JSON.stringify(a) === JSON.stringify(b)
      },
      saveAndReview: function() {
        this.validateForm()
        if(!this.isFormValid()) return
        if(this.automation.campaign_status != "draft") {
          this.requestSave()  
        }
        console.log("Go to summary page")
      },

      validateForm: function() {
        // No need to validate start date and campaign name cus they have default values

        if(!this.automation.send_continuously && isEmpty(this.automation.send_date_end)) {
          this.errors.endDate = true
        } 

        if(!this.$refs.frontEditor.$data.attributes.background_url) {
          this.errors.uploadedFrontDesign = true
        }

        if(!this.$refs.backEditor.$data.attributes.background_url) {
          this.errors.uploadedBackDesign = true 
        }

        if(this.automation.international) {
          if(!isEmpty(this.returnAddress.name) ||
            !isEmpty(this.returnAddress.address_line1) ||
            !isEmpty(this.returnAddress.city) ||
            !isEmpty(this.returnAddress.zip) ||
            !isEmpty(this.returnAddress.state)) {
            this.errors.returnAddress = true
            $(".return-address-general-error").show();
          }
        }
      },

      isFormValid: function() {
        for (const item in this.errors) {
          if(this.errors[item]) return false
        }
      },
      // We can perform this check because autosave every second
      isCampaignNew: function() {
        const createdAt = new Date(this.automation.created_at)
        const updatedAt = new Date(this.automation.updated_at)
        return createdAt.getTime() == updatedAt.getTime() ? true : false
      },

      cancel: function() {
        if(!this.isEditExistCampaign) {
          this.saveAutomation()
          Turbolinks.visit('/automations')
        } else {
          this.isCancel = true
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

  .error{
    color: red
  }

  .d-none{
    display: none
  }

  .filter-config {
    display: block;
    width: 850px;
  }

  .filter-section-title {
    background: #eee;
    padding: 8px;
    font-size: 15px;
    font-weight: bold;
    text-align: center;
    margin-top: 15px;
  }

  .add-more-filter-btn {
    border-style: dotted;
    width: 100%;
    margin-top: 15px;
  }

  .vdp-datepicker{
    display: inline-block;
  }

  .flex-center,
  .send-continuously-option{
    display: flex;
    align-items: center;
  }

  .pt-ongoing-checkbox {
    padding-top: 10px;
  }

  .campaign-section {
    width: 300px;
  }

  .datepicker-with-icon{
    align-items: center;
    cursor: pointer;
    display: flex;
    .icon-calendar {
      width: 21px;
      height: 21px;
      border: 1px solid;
      border-left: 0;
      display: flex;
      justify-content: center;
      align-items: center;
    }
  }

  .error{
    color: red
  }

  .campaign-name-error{
    display: none;
  }

  .review-and-continue-btn.text-white,
  .cancel-btn.text-white {
    color: white;
  }

  .cancel-btn {
    background-color: #647786;
    border-radius: 5px;
    font-weight: bold;
    box-shadow: 2px 4px #888888;
  }

  .review-and-continue-btn {
    background-color: #0150ee;
    border-radius: 5px;
    font-weight: bold;
    box-shadow: 2px 4px #888888;
  }

  .text-right {
    text-align: right;
  }

  .invalid {
    border: 2px solid red;
  }
</style>
