<template>
  <div class="automation_form">
    <h1 class="page-header">{{ automation.campaign_name }}</h1>
    <hr/>
    <h2>Campaign Settings</h2>
    <div class="automation-section">
      <span>
        <strong><small :class="{error: errors.campaignName}" v-if="errors.campaignName">*</small> Campaign name</strong>
        <input id="campaign_name" v-model="automation.campaign_name" :class="[errors.campaignName ? 'invalid' : '', 'error-wrapper']" maxlength="60">
        <span class="error campaign-name-error">This field is required.</span>
      </span>
    </div>

    <div class="automation-section">
      <strong>Type</strong>
      <span v-if="automation.campaign_status == 'draft' || automation.campaign_type == 'automation'">
        <input type="radio" id="automation" value="automation" v-model="campaign_type" v-on:click="setBudgetType">
        <label for="automation">Automation</label>
      </span>
      <!-- <span v-if="automation.campaign_status == 'draft' || automation.campaign_type == 'one_off'">
        <input type="radio" id="one_off" value="one_off" v-model="campaign_type" v-on:click="setBudgetType">
        <label for="one_off">One-off</label>
      </span> -->
    </div>

    <div class="automation-section" v-if="campaign_type =='automation'">
      <strong>Monthly budget</strong>
      <span>
        $ <input type="numer" v-on:keypress="restrictToNumber($event)" id="budget_limit" v-model="budget" maxlength = "10">
      </span>
    </div>

    <div class="automation-section d-flex" v-if="campaign_type =='one_off'">
      <div class="align-self-center">
        <strong class="f-14">Campaign schedule</strong>
      </div>
      <div>
        <div class="filter-config nested-toggle">
          <div class="datepicker-with-icon">
            <span style="width: 80px">Start date:</span>
            <datepicker
              v-model="automation.send_date_start"
              :disabled-dates="disabledDates"
              name="send_date_start"
              ref="sendDateStart"
              @selected="changeSendDateEnd"
              format="MMM dd, yyyy"
              :disabled="isStartDateDisable"
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

    <div class="automation-section d-flex" v-if="campaign_type =='automation'">
      <div class="align-self-center">
        <strong class="f-14">Campaign schedule</strong>
      </div>
      <div class="flex-center">
        <div class="campaign-section nested-toggle">
          <div class="datepicker-with-icon">
            <span style="width: 80px">Start date:</span>
            <datepicker
              v-model="automation.send_date_start"
              :disabled-dates="disabledDates"
              name="send_date_start"
              ref="sendDateStart"
              @selected="changeSendDateEnd"
              format="MMM dd, yyyy"
              :disabled="isStartDateDisable"
            ></datepicker>
            <div class="icon-calendar" v-on:click="openSendDateStartDatePicker">
              <font-awesome-icon icon="calendar-alt"/>
            </div>
          </div>
        </div>
        <div class="campaign-section nested-toggle" v-if="automation.send_continuously === false">
          <div class="datepicker-with-icon">
            <span style="width: 80px"><small :class="{error: errors.endDate}" v-if="errors.endDate">*</small> End date:</span>
            <div class="datepicker-with-icon">
              <datepicker
                v-model="automation.send_date_end"
                :disabled-dates="disabledEndDates"
                name="sendDateEnd"
                ref="sendDateEnd"
                :disabled="automation.send_continuously"
                format="MMM dd, yyyy"
                :input-class="{invalid: errors.endDate}"
              ></datepicker>
              <div class="icon-calendar" v-on:click="openSendDateEndDatePicker">
                <font-awesome-icon icon="calendar-alt"/>
              </div>
            </div>
          </div>
        </div>
        <div class="send-continuously-option align-self-center">
          <span>
            <input id="send-continuously" :class="{'invalid-checkbox': errors.endDate}" type="checkbox" @click="triggerErrorCheckbox" v-model="automation.send_continuously" />
          </span>
          <label for="send-continuously" class="noselect">- Ongoing</label>
        </div>
      </div>
    </div>
    <!-- <div :class="[errors.returnAddress ? 'invalid' : '', 'automation-section']">
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
    </div> -->
    <h2 class="d-inline-block">Customer Filters</h2>
    <button @click="downloadCSV"> CSV </button>
    <div :class="'filter-config nested-toggle row'" :showError="errors.filters">
      <div id="accepted-section">
        <div class="filter-section-title">Include these customers</div>
        <filter-option
          v-for="(filter, index) in acceptedFilters"
          :filter="filter"
          :key="filter.selectedFilter"
          @filterChange="filterChange"
          @filterRemove="filterRemove"
          collection="accepted"
          :index="index"
          :filterConditions="filterConditions"
          :filterOptions="availableFilters('accepted', index)"
          :checkingError="checkingError"
        />
        <button type="button" class="add-more-filter-btn" id="add-accepted-filter" @click="addFilter('accepted')">Add Filter</button>
      </div>
      <div id="removed-section">
        <div class="filter-section-title">Exclude these customers</div>
        <filter-option
          v-for="(filter, index) in removedFilters"
          :filter="filter"
          :key="filter.selectedFilter"
          @filterChange="filterChange"
          @filterRemove="filterRemove"
          collection="removed"
          :index="index"
          :filterConditions="filterConditions"
          :filterOptions="availableFilters('removed', index)"
          :checkingError="checkingError"
        />
        <button type="button" class="add-more-filter-btn" id="add-removed-filter" @click="addFilter">Add Filter</button>
      </div>
    </div>

    <hr />
    <card-editor
      ref="frontEditor"
      :isBack="false"
      :json="automation.front_json"
      :discount_pct.sync="automation.discount_pct"
      :discount_exp.sync="automation.discount_exp"
      :aws_sign_endpoint="awsSignEndpoint"
      :checkingError="checkingError"
      :errorPresent.sync="errors.uploadedFrontDesign"
    />
    <hr />
    <card-editor
      ref="backEditor"
      :isBack="true"
      :json="automation.back_json"
      :discount_pct.sync="automation.discount_pct"
      :discount_exp.sync="automation.discount_exp"
      :aws_sign_endpoint="awsSignEndpoint"
      :checkingError="checkingError"
      :errorPresent.sync="errors.uploadedBackDesign"
    />

    <div class="text-right">
      <div v-if="id && automation.campaign_status != 'draft' && automation.campaign_status != 'complete'">
        <button class="mdc-button mdc-button--stroked" @click="returnToCampaignList" :disabled="pausedSubmitForm">Discard</button>
        <button class="mdc-button mdc-button--raised" @click="saveAndReturn" :disabled="pausedSubmitForm">Save Changes</button>
      </div>
      <div v-else>
        <button class="mdc-button mdc-button--stroked" @click="saveAndReturn" :disabled="pausedSubmitForm">Save changes</button>

        <button class="mdc-button mdc-button--raised" v-if="isUserHasPaymentMethod" @click="saveAndStartSending" :disabled="pausedSubmitForm">Start Sending</button>
        <button class="mdc-button mdc-button--raised" v-else @click="saveAndCheckout" :disabled="pausedSubmitForm">Add payment and start sending</button>
      </div>
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
  import { DEFAULT_DISCOUNT_PERCENTAGE, DEFAULT_WEEK_BEFORE_DISCOUNT_EXPIRE, MAXIMUM_CAMPAIGN_NAME_LENGTH } from './config';
  window.$ = $
  const CAMPAIGN_STATUS_FOR_DISABLE_DATE = ["sending", "complete", "out_of_credit", "error", "paused"];

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
      },
      isUserHasPaymentMethod: {
        type: Boolean
      },
      shared: {
        type: Object
      },
      currentShop: {
        type: Object,
        required: true
      },
    },
    created() {
      this.initializeStartDatepicker();
    },

    beforeDestroy: function() {
      window.clearInterval(this.interval)
    },

    mounted: function() {
    },
    data: function() {
      return {
        onSelectState: this.returnAddress.state,
        enableAddReturnAddress: false,
        acceptedFilters: [],
        removedFilters: [],
        budget_type: this.automation.budget_type ? this.automation.budget_type : "non_set",
        budget: this.automation.budget_type == "monthly" ? this.automation.budget : null,
        willShowBudgetType: true,
        campaign_type: this.automation.campaign_type ? this.automation.campaign_type : "automation",
        willShowDailySendingSchedule: false,
        disabledDates: {},
        isCancel: false,
        isStartDateDisable: false,
        saved_automation: {}, // Use with autosave, play as backup when user don't want to change campaign any more
        errors: {
          endDate: false,
          uploadedFrontDesign: true,
          uploadedBackDesign: true,
          returnAddress: false,
          campaignName: false,
          filters: false
        },
        filterConditions: [],
        filterOptions: [],
        interval: null,
        pausedSubmitForm: false,
        checkingError: false
      }
    },

    computed: {
      disabledEndDates:{
        get: function(){
          const today = new Date()
          today.setHours(0,0,0,0)
          return {
            to: today
          }
        }
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
          this.automation.budget = 0
        } else {
          this.budget_type = "monthly"
          this.automation.budget_update = value
          this.automation.budget = value
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
      this.automation.send_date_start = this.automation.send_date_start || new Date();
      
      // Render added filters from filter_attributes to accepted/removed list
      if (this.automation.filters_attributes[0]) {
        let filters = this.automation.filters_attributes[0].filter_data;
        // Convert filter_data of filter to list of filters
        this.convertRawFilters(filters);
      }
      // Get all filter options
      this.getAllFilterOptionValues();
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
        this.automation.campaign_type = campaign_type
      },

      fetchDataFromUI: function() {

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
          this.automation.discount_pct = DEFAULT_DISCOUNT_PERCENTAGE;
          this.automation.discount_exp = DEFAULT_WEEK_BEFORE_DISCOUNT_EXPIRE;
        }

        this.automation.budget_type = this.budget_type
        this.automation.campaign_type = this.campaign_type
        this.automation.return_address_attributes = this.returnAddress
      },
      // Get all filters and conditions
      getAllFilterOptionValues() {
        axios.get("/targeting/get_filters").then((response) => {
          this.filterOptions = response.data.filters;
          this.filterConditions = response.data.conditions;
        });
      },
      // Remove selected filter options => next filter not have existed filter
      availableFilters(collection, index) {
        let filters = collection == "accepted" ? this.acceptedFilters : this.removedFilters;
        let selectedFilters = filters.map(filter => filter.selectedFilter);
        return this.filterOptions.filter(item => !(selectedFilters.includes(item[1]) && selectedFilters.indexOf(item[1]) != index));
      },
      addFilter(list) {
        let defaultValue = {selectedFilter: "", selectedCondition: 0, value: null};
        if (list == "accepted") {
          if (this.acceptedFilters.length < this.filterOptions.length) this.acceptedFilters.push(defaultValue);
        } else {
          if (this.removedFilters.length < this.filterOptions.length) this.removedFilters.push(defaultValue);
        }
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
      // Convert filter_data of filter to list of filters
      convertRawFilters(rawValue) {
        ["accepted", "removed"].forEach(section => {
          Object.keys(rawValue[section]).forEach(value => {
            let defaultValue = {selectedFilter: value, selectedCondition: rawValue[section][value].condition, value: rawValue[section][value].value};
            section == "accepted" ? this.acceptedFilters.push(defaultValue) : this.removedFilters.push(defaultValue);
          });
        });
      },
      // Generate/update filter_attribute
      collectFilters() {
        let collectedFilters = this.convertFiltersToParams();
        let id = this.automation.filters_attributes[0] ? this.automation.filters_attributes[0].id : null;
        this.automation.filters_attributes = [{id:id, filter_data: collectedFilters}];
      },
      // Convert filter lists to filter_data json of Filter object
      convertFiltersToParams() {
        let res = {accepted: {}, removed: {}};
        // Prevent error
        // Cannot read property '[object Array]' of undefined
        const filters = [this.acceptedFilters, this.removedFilters].filter(Boolean)
        filters.forEach((collection, index) => {
          let tmp = this.generateFilterToObject(collection);
          index == 0 ? res["accepted"] = tmp : res["removed"] = tmp;
        })
        return res;
      },
      // Generate a filter item into filter object
      generateFilterToObject(list) {
        let tmp = {};
        list.forEach((item) => {
          if (item["value"] == null) return;
          tmp[item["selectedFilter"]] = {condition: item["selectedCondition"], value: item["value"]};
        });
        return tmp;
      },
      downloadCSV() {
        let url = `/targeting/get.xlsx`;
        let body = this.convertFiltersToParams();
        let _this = this;
        axios.post(url, body, {responseType: 'blob'}).then(function(response) {
          const url = window.URL.createObjectURL(new Blob([response.data], {type: 'application/vnd.ms-excel'}))
          const link = document.createElement('a')
          link.href = url
          link.setAttribute('download', `${_this.currentShop.name}_Filters.xlsx`)
          document.body.appendChild(link)
          link.click()
        }).catch(function (error) {
          console.log(error)
        });
      },
      isTwoJsonEqual: function(a, b) {
        return JSON.stringify(a) === JSON.stringify(b)
      },

      saveWithValidation: function(f) {
        this.validateForm();
        this.$nextTick(() => {
          if (isEmpty($(".invalid"))) return false;
          $(".invalid")[0].scrollIntoView({
            behavior: "smooth",
            block: "start"
          })
        })
        if(!this.isFormValid()) return false;
        this.fetchDataFromUI();
        this.shared.campaign = {...this.automation};

        this.collectFilters();
        return true;
      },

      saveAutomation(func) {
        // Prevent to submit form after click submit
        this.pausedSubmitForm = true;
        setTimeout(() => this.pausedSubmitForm = false, 5000);

        if (this.id) {
          axios.put(`/automations/${this.id}.json`, { card_order: this.automation})
            .then((response) => {
              let id = JSON.parse(response.data.campaign).id;
              func(id);
            }).catch((error) => console.log(error));
        } else {
          axios.post(`/automations.json`, { card_order: this.automation})
            .then((response) => {
              let id = JSON.parse(response.data.campaign).id;
              func(id);
            }).catch((error) => console.log(error));
        }
      },

      saveAndReturn: function() {
        // If there're some errors in save process => return
        if (!this.saveWithValidation()) return;
        if(this.automation.campaign_status == "complete") {
          this.shared.campaign.campaign_status = this.currentShop.credit > 0.89 ? "sending" : "out_of_credit"
        }
        this.saveAutomation(this.returnToCampaignList);
      },

      saveAndStartSending: function() {
        // If there're some errors in save process => return
        if (!this.saveWithValidation()) return;
        this.shared.campaign.campaign_status = this.currentShop.credit > 0.89 ? (this.automation.campaign_status != "complete" ? "processing" : "sending") : "out_of_credit";
        this.saveAutomation(this.automation.campaign_status != "complete" ? this.startSending : this.returnToCampaignList);
      },

      saveAndCheckout: function() {
        // If there're some errors in save process => return
        if (!this.saveWithValidation()) return;
        this.shared.campaign = null;
        this.saveAutomation(this.goToCheckoutPage);
      },

      returnToCampaignList: function() {
        Turbolinks.clearCache();
        Turbolinks.visit('/campaigns', {flush: true});
      },

      goToCheckoutPage: function(id) {
        Turbolinks.visit(`/subscriptions/new?campaign_id=${id}`);
      },

      startSending(id) {
        this.shared.campaign.id = id
        axios.get(`/automations/${id}/start_sending.json`).then(() => this.returnToCampaignList());
      },

      validateForm: function() {
        // No need to validate start date cus they have default values
        this.checkingError = !this.checkingError;

        if(this.isSendDateEndInvalid()) {
          this.errors.endDate = true
        } else {
          this.errors.endDate = false
        }

        if(isEmpty(this.front_side_attribute) ||
          this.automation.discount_pct == 0 ||
          this.automation.discount_exp == 0) {
          this.errors.uploadedFrontDesign = true
        } else {
          this.errors.uploadedFrontDesign = false
        }

        if(isEmpty(this.back_side_attribute) ||
          this.automation.discount_pct == 0 ||
          this.automation.discount_exp == 0) {
          this.errors.uploadedBackDesign = true
        } else {
          this.errors.uploadedBackDesign = false
        }

        if(isEmpty(this.automation.campaign_name) || this.automation.campaign_name.length > MAXIMUM_CAMPAIGN_NAME_LENGTH) {
          this.errors.campaignName = true
        } else {
          this.errors.campaignName = false
        }

        this.filtersValidation();
        if(this.automation.international) {
          if(isEmpty(this.returnAddress.name) ||
            isEmpty(this.returnAddress.address_line1) ||
            isEmpty(this.returnAddress.city) ||
            isEmpty(this.returnAddress.zip) ||
            isEmpty(this.returnAddress.state)) {
            this.errors.returnAddress = true
            $(".return-address-general-error").show();
          } else {
            this.errors.returnAddress = false
          }
        }
      },

      isFilterComplete: function() {
        for (let element of this.acceptedFilters.concat(this.removedFilters))
          for(let item in element)
            if (!element[item] || isEmpty(element[item].toString())) return false;
        return true;
      },

      isFormValid: function() {
        for (const item in this.errors) {
          if(this.errors[item]) return false
        }
        return true
      },

      disableCampaign: function(campaign_id) {
        const _this = this
        axios.put(`/automations/${campaign_id}.json`, { card_order: {enabled: false} }).then(function(response) {
          _this.$forceUpdate()
        })
      },

      restrictToNumber: function(e) {
        if(e.charCode === 0 || /\d/.test(String.fromCharCode(e.charCode))) return true
        e.preventDefault()
      },

      initializeStartDatepicker() {
        this.isStartDateDisable = this.disableStartDate();
        if(isEmpty(this.automation.send_date_start)) {
          this.automation.send_date_start = new Date()
        }
        const today = new Date()
        today.setDate(today.getDate() - 1)
        this.disabledDates = {
          to: today
        }
      },

      disableStartDate() {
        return CAMPAIGN_STATUS_FOR_DISABLE_DATE.includes(this.automation.campaign_status);
      },

      triggerErrorCheckbox() {
        this.errors.endDate = false;
        this.automation.send_continuously = true;
      },

      isSendDateEndInvalid() {
        if(this.automation.send_continuously) return false

        if(this.automation.send_date_end) {
          const date_start = new Date(this.automation.send_date_start)
          const date_end = new Date(this.automation.send_date_end)
          date_start.setHours(0,0,0,0)
          date_end.setHours(0,0,0,0)
          if(date_end >= date_start) return false
        }

        return true
      },

      orderDateFiltersNotConflict(col) {
        let orderDateFilters = col.filter(filter => filter.selectedFilter.includes("order_date"));
        if (orderDateFilters.length != 2) return true;
        let firstOrdFilter = orderDateFilters.filter(filter => filter.selectedFilter == "first_order_date")[0];
        let lastOrdFilter = orderDateFilters.filter(filter => filter.selectedFilter == "last_order_date")[0];
        // let firstOrderDateCompareValue = new Date(firstOrderDateVal.includes("&") ? firstOrderDateVal.split : firstOrderDateVal);

        let firstOrdCompareValue = null;
        switch (firstOrdFilter.selectedCondition) {
          case "after":
            firstOrdCompareValue = new Date(firstOrdFilter.value);
            break;
          case "between_date":
            if (firstOrdFilter.value.split("&")[0] != "") {
              firstOrdCompareValue = new Date(firstOrdFilter.value.split("&")[0]);
            }
            break;
          case "between_number":
            let numberOfDay = firstOrdFilter.value.split("&")[1];
            if (numberOfDay != "") {
              let today = new Date();
              firstOrdCompareValue = today.setDate(today.getDate() - parseInt(numberOfDay));
            }
            break;
          case "matches_number":
            let today = new Date();
            firstOrdCompareValue = today.setDate(today.getDate() - parseInt(firstOrdFilter.value));
            break;
          default:
            break;
        }
        if (!firstOrdCompareValue) return true;

        let lastOrdCompareValue = null;
        switch (lastOrdFilter.selectedCondition) {
          case "before":
            lastOrdCompareValue = new Date(lastOrdFilter.value);
            break;
          case "between_date":
            if (lastOrdFilter.value.split("&")[1] != "") {
              lastOrdCompareValue = new Date(lastOrdFilter.value.split("&")[1]);
            }
            break;
          case "between_number":
            let numberOfDay = lastOrdFilter.value.split("&")[0];
            if (numberOfDay != "") {
              let today = new Date();
              lastOrdCompareValue = today.setDate(today.getDate() - parseInt(numberOfDay));
            }
            break;
          case "matches_number":
            let today = new Date();
            lastOrdCompareValue = today.setDate(today.getDate() - parseInt(lastOrdFilter.value));
            break;
          default:
            break;
        }
        if (!lastOrdCompareValue) return true;

        if (lastOrdCompareValue <= firstOrdCompareValue) {
          this.markInvalidDateFilter(col, firstOrdFilter, lastOrdFilter);
          return false;
        } else {
          this.markInvalidDateFilter(col, firstOrdFilter, lastOrdFilter, true);
          return true;
        }
      },

      markInvalidDateFilter(collection, firstOrd, lastOrd, isUnmark=false) {
        if (isUnmark) {
          $($(".filter-line")[collection.indexOf(firstOrd)]).find(".f-value input").removeClass("invalid");
          $($(".filter-line")[collection.indexOf(lastOrd)]).find(".f-value input").removeClass("invalid");
        } else {
          $($(".filter-line")[collection.indexOf(firstOrd)]).find(".f-value input").addClass("invalid");
          $($(".filter-line")[collection.indexOf(lastOrd)]).find(".f-value input").addClass("invalid");
        }
      },
      filtersValidation() {
        if (this.isFilterComplete() && this.orderDateFiltersNotConflict(this.acceptedFilters)) {
          this.errors.filters = false;
        } else {
          this.errors.filters = true;
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
    border: 1px solid red;
  }
  
  .d-inline-block {
    display: inline-block;
  }

  .error-wrapper {
    padding-left: 2px;
    padding-top: 2px;
    padding-bottom: 2px;
  }

  .d-flex {
    display: flex;
  }

  .align-self-center {
    align-self: center;
  }

  .f-14 {
    font-size: 14px;
  }

  .h-32 {
    height: 32px;
  }

  .page-header {
    height: 60px;
    display: flex;
    align-items: center;
    margin-top: 0;
  }

  .invalid-checkbox {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    outline: 1px solid red;
    width: 13px;
    height: 13px;
  }

</style>
