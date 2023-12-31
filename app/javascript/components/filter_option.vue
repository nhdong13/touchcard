<template>
  <div class="filter-line">
    <input v-model="filter.selectedFilter" @change="filterChange" class="d-none filter-value" />
    <div class="position-relative">
      <select class="filter-dropdown" v-model="selectedFilter" @change="detectFilter">
        <option v-for="option in filterOptions" :key="option[1]" :value="option[1]">{{option[0]}}</option>
      </select>
      <font-awesome-icon icon="chevron-down" class="select-dropdown-arrow" />
    </div>

    <div class="switcher-options" v-if="['order_tag', 'discount_code'].includes(selectedFilter)">
      <span>Any orders</span>
      <switcher :value="switcherValue" @toggle="switcherToggle" />
      <span>Last order</span>
    </div>

    <div class="position-relative">
      <select class="option-dropdown" v-if="filter.selectedFilter != ''" v-model="filter.selectedCondition" @change="optionChange">
        <option v-for="condition in filterConditions" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]" :disabled="condition[1].includes('disable_display') || condition[1] == '' ? true : false">{{condition[0]}}</option>
      </select>
      <font-awesome-icon icon="chevron-down" class="select-dropdown-arrow" />
    </div>

    <!-- Common 2 input fields -->
    <div :class="['order_tag', 'discount_code'].includes(selectedFilter) ? 'f-value-2' : 'f-value'" v-if="showSecondInput() && !showDiscountAmountInput()">
      <datepicker class="valueInput" v-model="value1" v-if="showDateInput()" @input="combineValue()" :use-utc="true" :disabled-dates="datePickerDisabledDates(true)" format="MMM dd, yyyy" :input-class="{invalid: showError}" />
      <font-awesome-icon icon="chevron-down" v-if="showDateInput()" @click="triggerDatepicker(1)" class="datepicker-arrow middle-arrow" />

      <input type="number" :class="['valueInput', {invalid: showError}]" v-model="value1" v-if="showNumberInput()" @change="combineValue()" :placeholder="numberInputPlaceholder('Min. ')" @keypress="preventDecimal($event)" min=0 />

      <span class="middle-text">and</span>

      <datepicker class="valueInput" v-model="value2" v-if="showDateInput()" @input="combineValue()" :use-utc="true" :disabled-dates="datePickerDisabledDates(false)" format="MMM dd, yyyy" :input-class="{invalid: showError}"/>
      
      <font-awesome-icon icon="chevron-down" v-if="showDateInput()" @click="triggerDatepicker(2)" class="datepicker-arrow" />

      <input type="number" :class="['valueInput', {invalid: showError}]" v-model="value2" v-if="showNumberInput()" @change="combineValue()" :placeholder="numberInputPlaceholder('Max. ')" @keypress="preventDecimal($event)" min=0 />

      <span class="middle-text" v-if="filter.selectedCondition == 'between_number' && filter.selectedFilter.includes('order_date')">days ago</span>
    </div>
    <!---->

    <!-- Zipcode filter -->
    <div :class="['f-value', {invalid: showError}]" v-else-if="showZipCodeInput()">
      <input type="number" class="valueInput" v-model="value1" v-if="showNumberInput()" @change="filter.value = `${value1}`" />
    </div>
    <!---->

    <!-- Discount amount filter -->
    <div :class="['f-value', {invalid: showError}]" v-else-if="showDiscountAmountInput()">
      <!-- switcher currency type for discount amount filter -->
      <div class="switcher-small-options">
        <span>$</span>
        <switcher :value="currencySwitcherValue" @toggle="currencySwitcherToggle" />
        <span>%</span>
      </div>
      <!---->
      <input type="number" class="valueInput" v-model="value1" v-if="showSecondInput()" @change="changeCurrencyValue()" :placeholder="numberInputPlaceholder('Min. ')" @keypress="preventDecimal($event)" min=0 />
      <input type="number" class="valueInput" v-model="value2" v-if="showSecondInput()" @change="changeCurrencyValue()" :placeholder="numberInputPlaceholder('Max. ')" @keypress="preventDecimal($event)" min=0 />

      <input type="number" class="valueInput" v-model="value1" @change="changeCurrencyValue" @keypress="preventDecimal($event)" min=0 v-else />
    </div>
    <!---->

    <!-- common single filter -->
    <div :class="['order_tag', 'discount_code'].includes(selectedFilter) ? 'f-value-2' : 'f-value'" v-else>
      <input type="text" :class="['valueInput', {invalid: showError}]" v-model="filter.value" v-if="showTextInput()" @change="filterChange" />
      <input type="number" :class="['valueInput', {invalid: showError}]" v-model="filter.value" v-else-if="showNumberInput()" @change="filterChange" @keypress="preventDecimal($event)" min=0 />

      <datepicker class="valueInput" v-model="filter.value" v-if="showDateInput()" @input="filterChange" :use-utc="true" :disabled-dates="lastOrderDateDisabledDates()" format="MMM dd, yyyy" :input-class="{invalid: showError}" />
      <font-awesome-icon icon="chevron-down" v-if="showDateInput()" @click="triggerDatepicker(1)" class="datepicker-arrow" />

      <treeselect :class="['valueInput', {invalid: showError}]" v-model="filter.value" v-if="showCountrySelect()" :multiple="true" :options="countriesList" placeholder="Any country" />

      <div :class="['f-value', {invalid: showError}]" v-if="showStateSelect()">
        <div class="position-relative">
          <select class="valueInput" v-model="selectedCountry" @change="countrySelected">
            <option v-for="country in countriesList" :key="country.id" :value="country.id">{{country.label}}</option>
          </select>
          <font-awesome-icon icon="chevron-down" class="select-dropdown-arrow" />
        </div>
        <treeselect class="valueInput" v-model="filter.value" :options="statesList" :multiple="true" placeholder="Any state" />
      </div>
      <vue-tags-input v-model="newtag" :tags="tags" @tags-changed="newTags => tagsChanged(newTags)" v-if="showCityOrTagsInput()" :class="['valueInput', {invalid: showError}]" />

      <span class="middle-text" v-if="(filter.selectedCondition == 'matches_number' || filter.selectedCondition == 'greater_number' || filter.selectedCondition == 'smaller_number') && filter.selectedFilter.includes('order_date')">days ago</span>
    </div>
    <!---->

    <font-awesome-icon icon="trash-alt" class="remove-filter-icon" v-if="filter.selectedFilter != ''" @click="removeFilter" />

  </div>
</template>
<script>
  import $ from 'jquery';
  import Datepicker from 'vuejs-datepicker';
  import axios from 'axios';
  import Switcher from './utilities/switcher.vue';
  import Treeselect from '@riophae/vue-treeselect';
  import './treeselect.css';
  import VueTagsInput from '@johmun/vue-tags-input';
  const FILTERS_SHOW_NUMBER_INPUT = ['number_of_order', 'last_order_total', 'all_order_total']; //'total_spend', 'referring_site', 'landing_site', 'discount_amount'];
  const NUMBER_CONDITIONS = ["matches_number", "between_number", "greater_number", "smaller_number"];
  const DATE_CONDITIONS = ["matches_date", "before", "between_date", "after"]; //"disable_display_1", "disable_display_2"];
  export default {
    components: {
      Datepicker,Switcher,Treeselect,VueTagsInput
    },
    props: ["filterOptions", "filterConditions","filter", "collection", "index", "checkingError"],
    beforeMount() {
      // Select first filter for new filter item
      if (this.filter.selectedFilter == "") {
        this.selectedFilter = this.filterOptions[0][1];
        this.detectFilter();
      }

      // Initialize variable for selected filter
      if (this.filter.selectedFilter.includes("any_") || (this.filter.selectedFilter.includes("last_") && !["last_order_date", "last_order_total"].includes(this.filter.selectedFilter))) {
        // Define any/last order filter
        this.switcherToggle(this.filter.selectedFilter.includes("last_"), false);
        this.selectedOrderCollectionOption = this.filter.selectedFilter.includes("last_") ? "last_" : "any_";
        this.selectedFilter = this.filter.selectedFilter.split(this.selectedOrderCollectionOption)[1];
      } else {
        this.selectedFilter = this.filter.selectedFilter;
      }

      // Set 2 inputs value for between input
      if (this.filter.value && this.filter.selectedCondition.toString().includes("between")) {
        this.value1 = this.filter.value.split("&")[0];
        this.value2 = this.filter.value.split("&")[1];

        // Separate if discount amount selected
        if (this.filter.selectedFilter == "discount_amount") {
          this.currencySwitcherValue = this.filter.value.substr(0, 1) == "%";
          this.value1 = this.value1.substr(1);
        }
      }

      // get values for address input
      if (this.filter.selectedFilter == "shipping_state" && this.filter.selectedCondition == "from") {
        this.getSelectedCountryByState();
      }
      if ((this.filter.selectedFilter == "shipping_city" && this.filter.selectedCondition == "from") || this.selectedFilter == "order_tag" || this.selectedFilter == "discount_code") {
        this.tags = this.filter.value.map(value => {return {text: value, tiClasses: ["ti-valid"]}});
      }
      this.getAllCountries();
      this.countrySelected();
    },
    data() {
      return {
        availableFilter: [],
        selectedFilter: "",
        value: null,
        value1: null,
        value2: null,
        selectedOrderCollectionOption: "any_",
        countriesList: [],
        statesList: [],
        switcherValue: false,
        selectedCountry: "USA",
        newtag: '',
        tags: [],
        currencySwitcherValue: false,
        showError: false
      }
    },
    watch: {
      checkingError: function(val) {
        this.showError = this.filter.value == '' || !this.filter.value;
      }
    },
    methods: {
      resetInputValue(filterChange = false) {
        if (filterChange) this.selectFirstConditionOption();
        this.filter.value = null;
        this.value = null;
        this.value1 = null;
        this.value2 = null;
      },
      showSecondInput() {
        return this.filter.selectedCondition.toString().includes("between");
      },
      showNumberInput() {
        return FILTERS_SHOW_NUMBER_INPUT.includes(this.filter.selectedFilter) ||
               (this.selectedFilter.includes("order_date") && NUMBER_CONDITIONS.includes(this.filter.selectedCondition)) ||
               (this.selectedFilter == "zip_code" && ["tag_is", "begin_with", "end_with"].indexOf(this.filter.selectedCondition) > -1);
      },
      showTextInput() {
        return ['referring_site', 'landing_site'].indexOf(this.filter.selectedFilter) > -1;
      },
      showDateInput() {
        return this.selectedFilter.includes("order_date") && DATE_CONDITIONS.includes(this.filter.selectedCondition);
      },
      showCountrySelect() {
        return this.filter.selectedFilter == "shipping_country" && this.filter.selectedCondition == "from";
      },
      showStateSelect() {
        return this.filter.selectedFilter == "shipping_state" && this.filter.selectedCondition == "from";
      },
      showCityOrTagsInput() {
        return (this.filter.selectedFilter == "shipping_city" && this.filter.selectedCondition == "from") ||
               (this.isFilter(['order_tag']) && ["tag_is", "tag_contain"].indexOf(this.filter.selectedCondition) > -1) ||
               (this.isFilter(['discount_code']) && ["tag_is", "tag_contain"].indexOf(this.filter.selectedCondition) > -1);  
      },
      showDiscountAmountInput() {
        return this.filter.selectedFilter == 'discount_amount';
      },
      showOption(option) {
        // return option == "" ||
        //       (this.selectedFilter.includes("order_date") && ["before", "between_date", "after", "between_number", "matches_number", "disable_display_1", "disable_display_2"].includes(option)) ||
        //       (['number_of_order', 'last_order_total', 'all_order_total'].includes(this.filter.selectedFilter) && ["matches_number", "between_number"].includes(option)) ||
        //       (['shipping_country', 'shipping_state', 'shipping_city'].indexOf(this.filter.selectedFilter) > -1 && option == "from") ||
        //       (this.isFilter(['order_tag', 'discount_code']) && ["tag_is", "tag_contain"].indexOf(option) > -1) ||
        //       (this.selectedFilter == "zip_code" && ["equal", "begin_with", "end_with"].indexOf(option) > -1) ||
        //       (this.selectedFilter == "shipping_company" && ["no", "yes"].indexOf(option) > -1) ||
        //       (this.selectedFilter == 'discount_amount' && ["discount_amount_matches", "discount_amount_between"].includes(option));
        return (FILTERS_SHOW_NUMBER_INPUT.includes(this.selectedFilter) && NUMBER_CONDITIONS.includes(option)) ||
               (this.selectedFilter.includes("order_date") && DATE_CONDITIONS.includes(option));
              // Hide days ago filters (this.selectedFilter.includes("order_date") && DATE_CONDITIONS.concat(NUMBER_CONDITIONS).includes(option);
      },
      isFilter(filterNames) {
        let correctFilter = false;
        filterNames.forEach(name => {if (this.filter.selectedFilter.indexOf(name) > -1) correctFilter = true});
        return correctFilter;
      },
      removeFilter() {
        this.$emit('filterRemove', this.filter, this.collection, this.index);
      },
      filterChange() {
        this.showError = false;
        $(".f-value input", this.$el).removeClass("invalid");
        this.$emit('filterChange', this.filter, this.collection, this.index);
      },
      optionChange() {
        this.resetInputValue(false);
        this.filterChange();
        if(this.filter.selectedFilter == "shipping_company") this.filter.value = this.filter.selectedCondition

      },
      detectFilter() {
        this.filter.selectedFilter = this.fullfillFilter();
        this.resetInputValue(true);
        this.filterChange();
        this.setDefaultInputValue();
      },
      fullfillFilter() {
        switch (this.selectedFilter) {
          case "order_tag":
          case "discount_code":
            return this.selectedOrderCollectionOption + this.selectedFilter
          default:
            return this.selectedFilter;
        }
      },
      combineValue() {
        if (this.value1 && this.value2 && this.value1 != "" && this.value2 != "" && this.is2InputsValid()) {
          this.filter.value = `${this.value1}&${this.value2}`;
        } else {
          this.filter.value = null;
        }
        this.filterChange();
      },
      switcherToggle(switcherValue, valueChange=true) {
        this.switcherValue = switcherValue;
        if (valueChange) {
          this.selectedOrderCollectionOption = switcherValue ? "last_" : "any_";
          this.detectFilter();
        }
      },
      currencySwitcherToggle(value) {
        this.currencySwitcherValue = value;
        this.changeCurrencyValue();
      },
      changeCurrencyValue() {
        let currencyType = this.currencySwitcherValue ? "%" : "$";
        if (this.filter.selectedCondition.includes("between")) {
            this.filter.value = this.isValidInputNumber() ? currencyType + (this.value1 || "") + "&" + (this.value2 || "") : null;
        } else {
          this.filter.value = this.value1 && this.value1 != "" ? currencyType + this.value1 : null;
        }
        this.filterChange();
      },
      is2InputsValid() {
        if (this.selectedFilter.includes("order_date") && this.filter.selectedCondition == "between_date") {
          let date1 = new Date(this.value1);
          let date2 = new Date(this.value2);
          return date1 < date2;
        } else {
          return parseFloat(this.value1) < parseFloat(this.value2);
        }
      },
      isValidInputNumber() {
        if ((!this.value1 || this.value1 =='') && (!this.value2 || this.value2 == '')) {
          return false;
        } else {
          if ((this.value1 && this.value1 != "") && (this.value2 && this.value2 != "")
              && (parseFloat(this.value1) > parseFloat(this.value2))) {
            return false;
          }
        }
        return true;
      },
      getAllCountries() {
        axios.get("/targeting/get_countries").then((response) => {
          this.countriesList = response.data;
        })
      },
      countrySelected() {
        axios.get("/targeting/get_states", {params: {country: this.selectedCountry}}).then((response) => {
          this.statesList = response.data;
        })
      },
      getSelectedCountryByState() {
        axios.get("/targeting/get_country_by_state", {params: {state: this.filter.value[0]}}).then((response) => {
          this.selectedCountry = response.data.result;
          this.countrySelected();
        })
      },
      tagsChanged(newTags) {
        this.tags = newTags;
        this.filter.value = newTags.map(tag => tag.text);
      },
      triggerDatepicker(el) {
        this.$el.getElementsByTagName("input")[el].click();
      },
      setDefaultInputValue() {
        if (this.filter.selectedFilter.includes("order_date")) {
          this.filter.value = null;
          this.value1 = null;
          this.value2 = null;
        } else if (this.filter.selectedFilter == "number_of_order" && this.filter.selectedCondition == "matches_number") {
          this.filter.value = 1;
        }
        this.filterChange();
      },
      selectFirstConditionOption() {
        if (['last_order_total', 'all_order_total'].includes(this.filter.selectedFilter)) {
          this.filter.selectedCondition = "matches_number";
          this.optionChange();
          return;
        }
        for (let condition of this.filterConditions) {
          if (this.showOption(condition[1]) && !condition[1].includes('disable_display')) {
            this.filter.selectedCondition = condition[1];
            this.optionChange();
            return;
          }
        };
      },
      showZipCodeInput() {
        return this.filter.selectedFilter == "zip_code"
      },
      showShippingCompanyInput() {
        return this.filter.selectedFilter == "shipping_company"
      },
      numberInputPlaceholder(side) {
        switch (this.selectedFilter) {
          case 'first_order_date':
          case 'last_order_date':
            return side + 'days ago';
          case 'last_order_total':
          case 'all_order_total':
            return side + 'amount';
          case 'number_of_order':
            return side + 'number of orders';
          case 'discount_amount':
            return side + 'discount';
          default:
            return '';
        }
      },
      preventDecimal(e) {
        if ((! ['order_total', 'discount_amount'].includes(this.selectedFilter) && e.key==='.') || e.key==='-' || e.key==='+') {e.preventDefault()};
        if (e.currentTarget.value.split(".")[1] && e.currentTarget.value.split(".")[1].length == 2) {e.preventDefault()};
        if (e.currentTarget.value == "" && e.key==='.') {e.preventDefault()};
      },
      datePickerDisabledDates(isMinInput = true) {
        if (this.selectedFilter === 'last_order_date') return this.lastOrderDateDisabledDates(isMinInput);
        if (isMinInput && this.value2) return {from: new Date(this.value2)};
        if (!isMinInput && this.value1) return {to: new Date(this.value1)};
      },

      lastOrderDateDisabledDates(isMinInput = false) {
        if (this.selectedFilter !== 'last_order_date') return;
        let today = new Date();
        today.setDate(today.getDate() - 1);
        if (isMinInput && this.value2) return { from: new Date(this.value2), to: today };
        if (!isMinInput && this.value1) return { to: new Date(this.value1) };
        return { to: today };
      }
    }
  }
</script>
<style scoped>
.filter-line {
  width: 910px;
  display: flex;
  margin-top: 15px;
}

.and-text {
  margin: 0;
  margin-bottom: 15px;
  text-align: center;
}

.filter-dropdown {
  width: 180px;
  margin-right: 10px;
}

.option-dropdown {
  width: 180px;
  margin-right: 10px;
}

.valueInput {
  width: 100%;
  /* margin-right: 4px; */
  height: 30px;
}

.switcher-options, .switcher-small-options {
  margin-right: 10px;
  display: flex;
  align-items: center;
  width: 220px;
}

.switcher-small-options {
  width: 85px;
  margin-right: 0;
}

.switcher-small-options span {
  margin-left: 5px;
  margin-right: 5px;
}

.switcher-options span {
  margin-left: 10px;
  margin-right: 10px;
  width: 100px;
}

.d-none {
  display: none;
}

.f-value {
  width: 500px;
  display: flex;
}

.f-value-2 {
  width: 270px;
  display: flex;
}

input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

input[type=number] {
  -moz-appearance: textfield;
}
</style>
<style lang="css">
.vue-tags-input {
  max-width: 100% !important;
}

.vue-tags-input .ti-input {
  border: 1px solid black !important;
  padding: 3px 5px !important;
  border-width: thin;
  border-radius: 3px;
  height: 30px;
}

.vue-tags-input .ti-input .ti-tags {
  margin: 0;
  height: 22px !important;
}

.vue-tags-input .ti-input .ti-tags .ti-tag {
  height: 22px !important;
  position: relative;
  background: #e3f2fd !important;
  color: #039be5 !important;
  padding: 2px 5px;
  margin: 0;
  margin-right: 5px;
}

.vue-tags-input .ti-input .ti-tags .ti-new-tag-input-wrapper {
  margin: 0 5px;
  padding: 0;
}

.vue-tags-input .ti-input .ti-tags .ti-new-tag-input-wrapper input {
  height: 22px;
}

.datepicker-arrow {
  position: absolute;
  left: 890px;
  margin-top: 9px; 
  filter: brightness(0%); 
  width: 0.75em !important;
}

.datepicker-arrow.middle-arrow {
  left: 622px;
}

.datepicker-arrow path {
  fill: #ccc;
}

.middle-text {
  margin: auto;
  padding: 0 6px;
  white-space: nowrap;
}

.remove-filter-icon {
  margin: auto;
  cursor: pointer;
}

select {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  padding: 0 2px;
}

.position-relative {
  position: relative;
}

.select-dropdown-arrow {
  position: absolute;
  right: 15px;
  margin-top: 9px;
  width: 0.75em !important;
  filter: brightness(0%); 
  top: 0;
  pointer-events: none;
}

.invalid {
  border: 1px solid red;
}
</style>
