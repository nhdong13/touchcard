<template>
  <div class="automation_form">
    <a :href="backUrl"  class="mdc-button mdc-button--stroked">Cancel</a>
    <button v-on:click="requestSave" class="mdc-button mdc-button--raised">Save</button>
    <hr>
    <!-- div v-cloak></div -->
    <h3>{{automation.type}}</h3>
    <strong>Send card <input type="number" min="0" max="52" v-model="automation.send_delay"> weeks after purchase</strong>
    <br>
      <br>
      <input id="automation-international-checkbox" type="checkbox" v-model="automation.international" @change="handleChangeInternationalCheck"/>
      <label for="automation-international-checkbox" class="noselect"><strong>Send outside USA</strong></label>
      <div class="attention-note nested-toggle" v-if="automation.international">
        <div><span><em>Note:</em></span>
          <ul>
            <li>
              <em>International postcards cost two credits.</em>
            </li>
            <li>
              <em>US Return address is required when sending outside USA.</em>
            </li>
          </ul>
        </div>
      </div>
      <br v-if="!automation.international">
      <br>
      <input id="return-address-checkbox" type="checkbox" v-model="enableAddReturnAddress"/>
      <label for="return-address-checkbox" class="noselect"><strong>Add Return Address</strong></label>
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
    <br>
    <br>
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
      <!-- <span>
        Minimum $: <input type="number" min="1" max="9999" v-model="automation.filters_attributes[automation.filters_attributes.length-1].filter_data.minimum">
      </span> -->
    </div>
    <hr>
    <br>
    <hr />
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
  import FilterOption from './components/filter_option.vue'
  import $ from 'jquery'
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
    data: function() {
      return {
        onSelectState: this.returnAddress.state,
        enableFiltering: (this.automation.filters_attributes.length > 0),
        enableAddReturnAddress: this.automation.international,
        acceptedFilters: [],
        removedFilters: [],
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

      enableAddReturnAddress: function(enable) {
        if(this.automation.international){
          if (!enable) {
            this.enableAddReturnAddress = true
            $(".return-address-general-error").show();
            $("#return-address-checkbox").prop("checked", true);
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
      'card-editor': CardEditor
    },
    beforeMount: function() {
      // Set defaults in case these props are passed as 'null'
      this.automation.discount_pct = this.automation.discount_pct || 20;
      this.automation.discount_exp = this.automation.discount_exp || 3;
      // console.log(this.automation);
      let last_index = this.automation.filters_attributes.length-1;
      let filters = this.automation.filters_attributes[last_index].filter_data;
      this.convertRawFilters(filters);
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

      handleChangeInternationalCheck: function() {
        if(!this.automation.international){
          $(".return-address-general-error").hide();
          $(".error").hide();
        } else {
          this.enableAddReturnAddress = true
        }
      },

      checkFormReturnAddressIsInvalid: function() {
        if(this.automation.international){
          if(!this.returnAddress.name ||
            !this.returnAddress.address_line1 ||
            !this.returnAddress.city ||
            !this.returnAddress.state ||
            !this.returnAddress.zip) {
              $(".return-address-general-error").show()
              return true;
            }
        } else {
          $(".return-address-general-error").hide()
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

        // Null out discount_pct and discount_exp for backwards-compatability (might not be essential)
        // Using `.showsDiscount` assumes card_editor.vue has created card_attributes objects from json
        if (!frontAttrs.showsDiscount && !backAttrs.showsDiscount ) {
          this.automation.discount_pct = null;
          this.automation.discount_exp = null;
        }

        if (this.checkFormReturnAddressIsInvalid()) return;

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
        let defaultValue = {selectedFilter: "", selectedCondition: 0, inputValue: null, dateValue: null};
        list == "accepted" ? this.acceptedFilters.push(defaultValue) : this.removedFilters.push(defaultValue);
      },
      filterChange(filter, collection, index) {
        collection == "accepted" ? this.acceptedFilters[index] = filter : this.removedFilters[index] = filter;
      },
      filterRemove(filter, collection, index) {
        collection == "accepted" ? this.acceptedFilters.splice(index, 1) : this.removedFilters.splice(index, 1);
      },
      convertRawFilters(rawValue) {
        ["accepted", "removed"].forEach(section => {
          rawValue[section].forEach(value => {
            let splitValue = value.split("#");
            let defaultValue = {selectedFilter: splitValue[0], selectedCondition: splitValue[1], inputValue: null, dateValue: null};
            this.useNumberInput(splitValue[0], splitValue[1]) ? defaultValue["inputValue"] = splitValue[2] : defaultValue["dateValue"] = splitValue[2];
            section == "accepted" ? this.acceptedFilters.push(defaultValue) : this.removedFilters.push(defaultValue);
          });
        });
      },
      collectFilters() {
        let collectedFilters = {accepted: [], removed: []};
        collectedFilters["accepted"] = this.acceptedFilters.map(item => {
          let value = this.useNumberInput(item["selectedFilter"], item["selectedCondition"]) ? item["inputValue"] : item["dateValue"];
          return value ? [item["selectedFilter"], item["selectedCondition"], value].join("#") : null;
        }).filter(item => item != null);
        collectedFilters["removed"] = this.removedFilters.map(item => {
          let value = this.useNumberInput(item["selectedFilter"], item["selectedCondition"]) ? item["inputValue"] : item["dateValue"];
          return value ? [item["selectedFilter"], item["selectedCondition"], value].join("#") : null;
        }).filter(item => item != null);
        let last_index = this.automation.filters_attributes.length-1;
        this.automation.filters_attributes[last_index].filter_data = collectedFilters;
        return this.automation.filters_attributes[last_index].filter_data;
      },
      useNumberInput(filter, condition) {
        return (['number_of_order', 'total_spend', 'last_order_total'].indexOf(filter) > -1) || ((['last_order_date', 'first_order_date'].indexOf(filter) > -1) && [6, 7, 8].indexOf(condition) > -1);
      },
      convertFiltersToParams() {
        let res = {};
        let tmp = this.acceptedFilters.length == 0 ? {} : {"filter": [], "condition": [], "value": []};
        this.acceptedFilters.forEach(item => {
          let value = this.useNumberInput(item["selectedFilter"], item["selectedCondition"]) ? item["inputValue"] : item["dateValue"];
          tmp["filter"].push(item["selectedFilter"]);
          tmp["condition"].push(item["selectedCondition"].toString());
          tmp["value"].push(value);
        });
        if (tmp != {}) {
          res["accepted"] = tmp;
        }

        tmp = this.removedFilters.length == 0 ? {} : {"filter": [], "condition": [], "value": []};
        this.removedFilters.forEach(item => {
          let value = this.useNumberInput(item["selectedFilter"], item["selectedCondition"]) ? item["inputValue"] : item["dateValue"];
          tmp["filter"].push(item["selectedFilter"]);
          tmp["condition"].push(item["selectedCondition"].toString());
          tmp["value"].push(value);
        });

        if (tmp != {}) {
          res["removed"] = tmp;
        }
        return res;
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
      }
    }
  }
</script>

<style scoped>
  [v-cloak] {
    display: none;
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
    width: 600px;
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
</style>
