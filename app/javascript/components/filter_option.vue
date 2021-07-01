<template>
  <div class="filter-line">
    <input v-model="filter.selectedFilter" @change="filterChange" class="d-none filter-value" />
    <select class="filter-dropdown" v-model="selectedFilter" @change="detectFilter">
      <option v-for="option in filterOptions" :key="option[1]" :value="option[1]">{{option[0]}}</option>
    </select>

    <div class="switcher-options" v-if="['order_tag', 'discount_code', 'order_total'].includes(selectedFilter)">
      <span v-if="selectedFilter == 'order_total'">All orders</span>
      <span v-else>Any orders</span>
      <switcher :value="switcherValue" @toggle="switcherToggle2" />
      <span>Last order</span>
    </div>

    <select class="option-dropdown" v-if="filter.selectedFilter != ''" v-model="filter.selectedCondition" @change="optionChange">
      <option v-for="condition in filterConditions" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]" :disabled="condition[1].includes('disable_display') || condition[1] == '' ? true : false">{{condition[0]}}</option>
    </select>

    <div :class="['order_tag', 'discount_code', 'order_total'].includes(selectedFilter) ? 'f-value-2' : 'f-value'" v-if="showSecondInput()">
      <datepicker class="valueInput" v-model="value1" v-if="showDateInput()" :input="combineValue()" :use-utc="true" /><!--  :disabled-dates="datePickerOptions()" /> -->
      <font-awesome-icon icon="caret-down" v-if="showDateInput()" @click="triggerDatepicker" class="datepicker-arrow middle-arrow" />

      <input type="number" class="valueInput" v-model="value1" v-if="showNumberInput()" @change="combineValue()" :placeholder="numberInputPlaceholder('Min. ')" />

      <span class="middle-text">and</span>

      <datepicker class="valueInput" v-model="value2" v-if="showDateInput()" :input="combineValue()" :use-utc="true" /><!--  :disabled-dates="datePickerOptions2()" /> -->
      <font-awesome-icon icon="caret-down" v-if="showDateInput()" @click="triggerDatepicker" class="datepicker-arrow" />

      <input type="number" class="valueInput" v-model="value2" v-if="showNumberInput()" @change="combineValue()" :placeholder="numberInputPlaceholder('Max. ')" />

      <span class="middle-text" v-if="filter.selectedCondition == 'between_number' && filter.selectedFilter.includes('order_date')">days ago</span>
    </div>
    <div class="f-value" v-else-if="showZipCodeInput()">
      <input type="number" class="valueInput" v-model="value1" v-if="showNumberInput()" @change="filter.value = `${value1}`" />
    </div>
    <div :class="['order_tag', 'discount_code', 'order_total'].includes(selectedFilter) ? 'f-value-2' : 'f-value'" v-else>
      <input type="text" class="valueInput" v-model="filter.value" v-if="showTextInput()" @change="filterChange" />
      <input type="number" class="valueInput" v-model="filter.value" v-else-if="showNumberInput()" @change="filterChange" @keypress="if ((filter.selectedFilter.includes('order_date') && $event.key==='.') || $event.key==='-' || $event.key==='+') $event.preventDefault()" min=0 />

      <datepicker class="valueInput" v-model="filter.value" v-if="showDateInput()" @change="filterChange" :use-utc="true" />
      <font-awesome-icon icon="caret-down" v-if="showDateInput()" @click="triggerDatepicker" class="datepicker-arrow" />

      <treeselect class="valueInput" v-model="filter.value" v-if="showCountrySelect()" :multiple="true" :options="countriesList" placeholder="Any country" />

      <div class="f-value" v-if="showStateSelect()">
        <select class="valueInput" v-model="selectedCountry" @change="countrySelected">
          <option v-for="country in countriesList" :key="country.id" :value="country.id">{{country.label}}</option>
        </select>
        <treeselect class="valueInput" v-model="filter.value" :options="statesList" :multiple="true" placeholder="Any state" />
      </div>
      <vue-tags-input v-model="newtag" :tags="tags" @tags-changed="newTags => tagsChanged(newTags)" v-if="showCityOrTagsInput()" class="valueInput" />

      <span class="middle-text" v-if="filter.selectedCondition == 'matches_number' && filter.selectedFilter.includes('order_date')">days ago</span>
    </div>

    <font-awesome-icon icon="trash-alt" class="remove-filter-icon" v-if="filter.selectedFilter != ''" @click="removeFilter" />

  </div>
</template>
<script>
  import $ from 'jquery';
  import Datepicker from 'vuejs-datepicker';
  import axios from 'axios';
  import Switcher from './switcher.vue';
  import Treeselect from '@riophae/vue-treeselect'
  import './treeselect.css';
  import VueTagsInput from '@johmun/vue-tags-input';
  export default {
    components: {
      Datepicker,Switcher,Treeselect,VueTagsInput
    },
    props: ["filterOptions", "filterConditions","filter", "collection", "index"],
    beforeMount() {
      // Select first filter for new filter item
      if (this.filter.selectedFilter == "") {
        this.selectedFilter = this.filterOptions[0][1];
        this.detectFilter();
      }

      // Initialize variable for selected filter
      if (this.filter.selectedFilter.includes("any_") || (this.filter.selectedFilter.includes("last_") && this.filter.selectedFilter != "last_order_date")) {
        // Define any/last order filter
        this.switcherToggle2(this.filter.selectedFilter.includes("last_"), false);
        this.selectedOrderCollectionOption = this.filter.selectedFilter.includes("last_") ? "last_" : "any_";
        this.selectedFilter = this.filter.selectedFilter.split(this.selectedOrderCollectionOption)[1];
      } else {
        this.selectedFilter = this.filter.selectedFilter;
      }
      if (this.filter.selectedCondition.toString().includes("between")) {
        this.value1 = this.filter.value.split("&")[0];
        this.value2 = this.filter.value.split("&")[1];
      }
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
      }
    },
    methods: {
      resetInputValue(filterChange = false) {
        if (filterChange) this.selectFirstConditionOption();
        this.value = null;
        this.value1 = null;
        this.value2 = null;
      },
      showSecondInput() {
        return this.filter.selectedCondition.toString().includes("between");
      },
      showNumberInput() {
        return ['number_of_order', 'total_spend', 'referring_site', 'landing_site'].includes(this.filter.selectedFilter) ||
               (["first_order_date", "last_order_date", "order_total"].includes(this.selectedFilter) && ["between_number", "matches_number"].includes(this.filter.selectedCondition)) ||
               (this.selectedFilter == "zip_code" && ["tag_is", "begin_with", "end_with"].indexOf(this.filter.selectedCondition) > -1);
      },
      showTextInput() {
        return ['referring_site', 'landing_site'].indexOf(this.filter.selectedFilter) > -1;
      },
      showDateInput() {
        return this.selectedFilter.includes("order_date") && (["between_date", "before", "after"].indexOf(this.filter.selectedCondition) > -1);
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
      showOption(option) {
        return option == "" ||
              (this.selectedFilter.includes("order_date") && ["before", "between_date", "after", "between_number", "matches_number", "disable_display_1", "disable_display_2"].indexOf(option) > -1) ||
              (['number_of_order', 'last_order_total', 'any_order_total'].includes(this.filter.selectedFilter) && ["matches_number", "between_number"].includes(option)) ||
              (['shipping_country', 'shipping_state', 'shipping_city'].indexOf(this.filter.selectedFilter) > -1 && option == "from") ||
              (this.isFilter(['order_tag', 'discount_code']) && ["tag_is", "tag_contain"].indexOf(option) > -1) ||
              (this.selectedFilter == "zip_code" && ["equal", "begin_with", "end_with"].indexOf(option) > -1) ||
              (this.selectedFilter == "shipping_company" && ["no", "yes"].indexOf(option) > -1)
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
          case "order_total":
            return this.selectedOrderCollectionOption + this.selectedFilter
          default:
            return this.selectedFilter;
        }
      },
      combineValue() {
        if (this.value1 == null || this.value1 < 0) {
          this.value1 = 0;
        }
        if (this.value2 == null) {
          this.value2 = this.value1;
        }
        this.filter.value = this.value1 && this.value2 ? `${this.value1}&${this.value2}` : null;
        this.filterChange();
      },
      switcherToggle2(switcherValue, valueChange=true) {
        this.switcherValue = switcherValue;
        if (valueChange) {
          this.selectedOrderCollectionOption = switcherValue ? "last_" : "any_";
          this.detectFilter();
        }
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
      triggerDatepicker() {
        this.$el.getElementsByTagName("input")[1].click();
      },
      setDefaultInputValue() {
        if (this.filter.selectedFilter.includes("order_date")) {
          this.filter.value = new Date();
        } else if (this.filter.selectedFilter == "number_of_order" && this.filter.selectedCondition == "matches_number") {
          this.filter.value = 1;
        }
        this.filterChange();
      },
      selectFirstConditionOption() {
        if (this.filter.selectedFilter.includes("order_total")) {
          this.filter.selectedCondition = "between_number";
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
          case 'order_total':
            return side + 'amount';
          default:
            return '';
        }
      }
    }
  }
</script>
<style scoped>
.filter-line {
  width: 850px;
  display: flex;
  margin-top: 15px;
}

.and-text {
  margin: 0;
  margin-bottom: 15px;
  text-align: center;
}

.filter-dropdown {
  width: 140px;
  margin-right: 10px;
}

.option-dropdown {
  width: 120px;
  margin-right: 10px;
}

.valueInput {
  width: 100%;
  margin-right: 4px;
  height: 30px;
}

.switcher-options {
  margin-right: 10px;
  display: flex;
  align-items: center;
  width: 220px;
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
  width: 540px;
  display: flex;
}

.f-value-2 {
  width: 310px;
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
  left: 830px;
  margin-top: 9px;  
}

.datepicker-arrow.middle-arrow {
  left: 540px;
}

.datepicker-arrow path {
  fill: #ccc;
}

.middle-text {
  margin: auto;
  padding-right: 6px;
  white-space: nowrap;
}

.remove-filter-icon {
  margin: auto;
  cursor: pointer;
}
</style>
