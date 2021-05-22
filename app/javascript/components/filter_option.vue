<template>
  <div class="filter-line">
    <input v-model="filter.selectedFilter" @change="filterChange" class="d-none filter-value" />
    <select class="filter-dropdown" v-model="selectedFilter" @change="detectFilter">
      <option v-for="option in availableFilter" :key="option[1]" :value="option[1]">{{option[0]}}</option>
    </select>
    <div class="date-options">
      <select class="date-options-dropdown" v-model="selectedDateOption" v-if="selectedFilter == 'order_date'" @change="detectFilter">
        <option v-for="option in DATE_OPTIONS" :key="option[1]" :value="option[1]">{{option[0]}}</option>
      </select>
    </div>
    <select class="option-dropdown" v-if="filter.selectedFilter != ''" v-model="filter.selectedCondition" @change="optionChange">
      <option v-for="condition in filterConditions" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]" :disabled="condition[1].includes('disable_display') || condition[1] == '' ? true : false">{{condition[0]}}</option>
    </select>
    <div class="f-value" v-if="showSecondInput()">
      <datepicker class="valueInput" v-model="value1" v-if="filter.selectedFilter != '' && !showNumberInput()" :input="combineValue()" :disabled-dates="datePickerOptions()" />
      <datepicker class="valueInput" v-model="value2" v-if="filter.selectedFilter != '' && !showNumberInput()" :input="combineValue()" :disabled-dates="datePickerOptions2()"> </datepicker>

      <input type="number" class="valueInput" v-model="value1" v-if="showNumberInput()" @change="combineValue()" />
      <input type="number" class="valueInput" v-model="value2" v-if="showNumberInput()" @change="combineValue()" />
    </div>
    <div class="f-value" v-else>
      <input type="text" class="valueInput" v-model="filter.value" v-if="showTextInput()" @change="filterChange" />
      <input type="number" class="valueInput" v-model="filter.value" v-else-if="showNumberInput()" @change="filterChange" />
      <datepicker class="valueInput" v-model="filter.value" v-else-if="filter.selectedFilter != '' && showDateInput()" @change="filterChange" />
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
  export default {
    components: {
      Datepicker
    },
    props: ["filter", "collection", "index"],
    beforeMount() {
      if (this.filter.selectedFilter.includes("order_date")) {
        this.selectedFilter = "order_date";
        this.selectedDateOption = this.filter.selectedFilter.split("order_date")[0];
      } else {
        this.selectedFilter = this.filter.selectedFilter;
      }
      if (this.filter.selectedCondition.toString().includes("between")) {
          this.value1 = this.filter.value.split("&")[0];
          this.value2 = this.filter.value.split("&")[1];
        }
      this.getAllFilterValues()
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
        return ['number_of_order', 'total_spend', 'last_order_total', 'shipping_country', 'shipping_state', 'referring_site', 'landing_site', 'order_tag', 'discount_code_used'].indexOf(this.filter.selectedFilter) > -1 ||
               (this.selectedFilter == "order_date" && ["between_number", "matches_number"].indexOf(this.filter.selectedCondition) > -1)
      },
      showTextInput() {
        return ['shipping_country', 'shipping_state', 'referring_site', 'landing_site', 'order_tag', 'discount_code_used'].indexOf(this.filter.selectedFilter) > -1
      },
      showDateInput() {
        return this.selectedFilter == "order_date" && (["between_date", "before", "after"].indexOf(this.filter.selectedCondition) > -1)
      },
      showSecondInput() {
        // return this.selectedFilter == "order_date" && (this.filter.selectedCondition == "4" || this.filter.selectedCondition == "7");
        return this.filter.selectedCondition.toString().includes("between");
      },
      showOption(option) {
        return option == "" ||
              (this.selectedFilter == "order_date" && ["before", "between_date", "after", "between_number", "matches_number", "disable_display_1", "disable_display_2"].indexOf(option) > -1) ||
              ((['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.filter.selectedFilter) > -1) && ["matches_number", "between_number"].indexOf(option) > -1);// ||
              // (['shipping_country', 'shipping_state', 'referring_site', 'landing_site'].indexOf(this.filter.selectedFilter) > -1 && option == "9") ||
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
        if (this.value2 == null || this.value2 < this.value1) {
          this.value2 = 999999999;
        }
        this.filter.value = this.value1 && this.value2 ? `${this.value1}&${this.value2}` : null;
        this.filterChange();
      },
      datePickerOptions() {
        return { from: this.value2 };
      },
      datePickerOptions2() {
        return { to: this.value1 };
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
  width: 180px;
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
  width: 130px;
  margin-right: 10px;
}

.d-none {
  display: none;
}

.f-value {
  width: 357px;
  display: flex;
}
</style>
