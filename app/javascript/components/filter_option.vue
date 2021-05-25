<template>
  <div class="filter-line">
    <input v-model="filter.selectedFilter" @change="filterChange" class="d-none filter-value" />
    <select class="filter-dropdown" v-model="selectedFilter" @change="detectFilter">
      <option v-for="option in availableFilter" :key="option[1]" :value="option[1]">{{option[0]}}</option>
    </select>
    <div class="date-options" v-if="selectedFilter == 'order_date'">
      <span>First order date</span>
      <switcher :value="switcherValue" @toggle="switcherToggle" />
      <span>Last order date</span>
    </div>
    <select class="option-dropdown" v-if="filter.selectedFilter != ''" v-model="filter.selectedCondition" @change="optionChange">
      <option v-for="condition in filterConditions" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]" :disabled="condition[1].includes('disable_display') || condition[1] == '' ? true : false">{{condition[0]}}</option>
    </select>
    <div class="f-value" v-if="showSecondInput()">
      <datepicker class="valueInput" v-model="value1" v-if="showDateInput()" :input="combineValue()" /><!--  :disabled-dates="datePickerOptions()" /> -->
      <datepicker class="valueInput" v-model="value2" v-if="showDateInput()" :input="combineValue()" /><!--  :disabled-dates="datePickerOptions2()" /> -->

      <input type="number" class="valueInput" v-model="value1" v-if="showNumberInput()" @change="combineValue()" />
      <input type="number" class="valueInput" v-model="value2" v-if="showNumberInput()" @change="combineValue()" />
    </div>
    <div class="f-value" v-else>
      <input type="text" class="valueInput" v-model="filter.value" v-if="showTextInput()" @change="filterChange" />
      <input type="number" class="valueInput" v-model="filter.value" v-else-if="showNumberInput()" @change="filterChange" />
      <datepicker class="valueInput" v-model="filter.value" v-if="showDateInput()" @change="filterChange" />
      <treeselect class="valueInput" v-model="filter.value" v-if="showCountrySelect()" :multiple="true" :options="countriesList" placeholder="Any country" />

      <div class="f-value" v-if="showStateSelect()">
        <select class="valueInput" v-model="selectedCountry" @change="countrySelected">
          <option v-for="country in countriesList" :key="country.id" :value="country.id">{{country.label}}</option>
        </select>
        <treeselect class="valueInput" v-model="filter.value" :options="statesList" :multiple="true" placeholder="Any state" />
      </div>
    </div>
    <div class="dropdown">
      <button type="button" class="more-action-btn" v-if="filter.selectedFilter != ''">...</button>
      <div class="dropdown-content">
        <p @click="removeFilter">Remove Filter</p>
      </div>
    </div>
  </div>
</template>
<script>
  import $ from 'jquery';
  import Datepicker from 'vuejs-datepicker';
  import axios from 'axios';
  import Switcher from './switcher.vue';
  import Treeselect from '@riophae/vue-treeselect'
  import './treeselect.css';
  export default {
    components: {
      Datepicker,Switcher,Treeselect
    },
    props: ["filter", "collection", "index"],
    beforeMount() {
      if (this.filter.selectedFilter.includes("order_date")) {
        this.selectedFilter = "order_date";
        this.selectedDateOption = this.filter.selectedFilter.split("order_date")[0];
        this.switcherValue = this.selectedDateOption == "first_" ? false : true;
      } else {
        this.selectedFilter = this.filter.selectedFilter;
      }
      if (this.filter.selectedCondition.toString().includes("between")) {
        this.value1 = this.filter.value.split("&")[0];
        this.value2 = this.filter.value.split("&")[1];
      }
      this.getAllFilterValues();
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
        selectedDateOption: "first_",
        DATE_OPTIONS: [["First order date", "first_"], ["Last order date", "last_"]],
        filterOptions: [],
        filterConditions: [],
        countriesList: [],
        statesList: [],
        switcherValue: false,
        selectedCountry: "US",
      }
    },
    methods: {
      getAllFilterValues() {
        axios.get("/targeting/get_filters").then((response) => {
          response.data.filters.forEach(filter => this.filterOptions.push(filter));
          response.data.conditions.forEach(condition => this.filterConditions.push(condition));
          this.resetAvailableFilter();
        });
      },
      resetAvailableFilter() {
        let selected = [];
        $(`#${this.collection}-section .filter-dropdown`).each(function() {
          selected.push($(this).val());
        });
        this.availableFilter = this.filterOptions.filter(el => el[1] == "" || !(selected.indexOf(el[1]) > -1));
      },
      resetInputValue(filterChange = false) {
        if (filterChange) this.filter.selectedCondition = "";
        this.value = null;
        this.value1 = null;
        this.value2 = null;
      },
      showNumberInput() {
        return ['number_of_order', 'total_spend', 'last_order_total', 'referring_site', 'landing_site', 'order_tag', 'discount_code_used'].indexOf(this.filter.selectedFilter) > -1 ||
               (this.selectedFilter == "order_date" && ["between_number", "matches_number"].indexOf(this.filter.selectedCondition) > -1);
      },
      showTextInput() {
        return ['referring_site', 'landing_site', 'order_tag', 'discount_code_used'].indexOf(this.filter.selectedFilter) > -1;
      },
      showDateInput() {
        return this.selectedFilter == "order_date" && (["between_date", "before", "after"].indexOf(this.filter.selectedCondition) > -1);
      },
      showSecondInput() {
        // return this.selectedFilter == "order_date" && (this.filter.selectedCondition == "4" || this.filter.selectedCondition == "7");
        return this.filter.selectedCondition.toString().includes("between");
      },
      showCountrySelect() {
        return this.filter.selectedFilter == "shipping_country" && this.filter.selectedCondition == "from";
      },
      showStateSelect() {
        return this.filter.selectedFilter == "shipping_state" && this.filter.selectedCondition == "from";
      },
      showOption(option) {
        return option == "" ||
              (this.selectedFilter == "order_date" && ["before", "between_date", "after", "between_number", "matches_number", "disable_display_1", "disable_display_2"].indexOf(option) > -1) ||
              ((['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.filter.selectedFilter) > -1) && ["matches_number", "between_number"].indexOf(option) > -1) ||
              (['shipping_country', 'shipping_state'].indexOf(this.filter.selectedFilter) > -1 && option == "from");
              // (['order_tag', 'discount_code_used'].indexOf(this.filter.selectedFilter) > -1 && option == "find_value")
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
      },
      detectFilter() {
        this.filter.selectedFilter = this.selectedFilter == "order_date" ? this.selectedDateOption + this.selectedFilter : this.selectedFilter;
        this.resetInputValue(true);
        this.filterChange();
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
      // datePickerOptions() {
      //   return { from: Date.parse(this.value2) };
      // },
      // datePickerOptions2() {
      //   return { to: Date.parse(this.value1) };
      // },
      switcherToggle(switcherValue) {
        this.selectedDateOption = switcherValue ? "last_" : "first_"
        this.switcherValue = switcherValue;
        this.detectFilter();
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

.more-action-btn {
  transform: rotate(90deg);
  border: none;
  background: none;
  font-size: 20px;
  font-weight: bold;
  padding: 3px 6px;
}

.dropdown:hover .dropdown-content {
  display: block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f9f9f9;
  min-width: 160px;
  z-index: 1;
}

.dropdown-content p {
  cursor: pointer;
}

.date-options {
  margin-right: 10px;
  display: flex;
  align-items: center;
  width: 272px;
}

.date-options span {
  margin-left: 10px;
  margin-right: 10px;
  width: 100px;
}

.d-none {
  display: none;
}

.f-value {
  width: 100%;
  display: flex;
}
</style>
