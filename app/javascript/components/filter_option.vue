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
    <select class="option-dropdown" v-if="filter.selectedFilter != ''" v-model="filter.selectedCondition" @change="filterChange">
      <option v-for="condition in CONDITIONS" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]" :disabled="condition[1].length > 2 ? true : false">{{condition[0]}}</option>
    </select>
    <div class="f-value" v-if="showSecondInput()">
      <input v-model="filter.dateValue" @change="filterChange" class="d-none" />
      <datepicker class="valueInput" v-model="dateValue" v-if="filter.selectedFilter != '' && !showNumberInput()" :input="detectValue('date')" :disabled-dates="datePickerOptions()" />
      <datepicker class="valueInput" v-model="dateValue0" v-if="filter.selectedFilter != '' && !showNumberInput()" :input="detectValue('date')" :disabled-dates="datePickerOptions2()"> </datepicker>

      <input v-model="filter.inputValue" @change="filterChange" class="d-none" />
      <input type="number" class="valueInput" v-model="inputValue" v-if="showNumberInput()" @change="detectValue('number')" />
      <input type="number" class="valueInput" v-model="inputValue0" v-if="showNumberInput()" @change="detectValue('number')" />
    </div>
    <div class="f-value" v-else>
      <datepicker class="valueInput" v-model="filter.dateValue" v-if="filter.selectedFilter != '' && !showNumberInput()" @change="filterChange" />
      <input type="number" class="valueInput" v-model="filter.inputValue" v-if="showNumberInput()" @change="filterChange" />
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
  export default {
    components: {
      Datepicker
    },
    props: ["filter", "collection", "index"],
    beforeMount() {
      if (this.filter.selectedFilter.includes("order_date")) {
        this.selectedFilter = "order_date";
        this.selectedDateOption = this.filter.selectedFilter.split("order_date")[0];

        if (this.filter.selectedCondition == "4") {
          this.dateValue = this.filter.dateValue.split("&")[0];
          this.dateValue0 = this.filter.dateValue.split("&")[1];
        }
        if (this.filter.selectedCondition == "7") {
          this.inputValue = this.filter.inputValue.split("&")[0];
          this.inputValue0 = this.filter.inputValue.split("&")[1];
        }
      } else {
        this.selectedFilter = this.filter.selectedFilter;
      }
      this.resetAvailableFilter();
    },
    data() {
      return {
        availableFilter: [],
        selectedFilter: "",
        dateValue: null,
        dateValue0: null,
        inputValue: null,
        inputValue0: null,
        selectedDateOption: "first_",
        FILTER_OPTIONS: [["Select a filter" , ""                ],
                         ["Number of orders", "number_of_order" ],
                         ["Total Spend"     , "total_spend"     ],
                         ["Order date"      , "order_date"      ],
                         ["Last order total", "last_order_total"]
                        ],
        DATE_OPTIONS: [["First order date", "first_"], ["Last order date", "last_"]],
        CONDITIONS: [["is", "0"], ["is greater than", "1"], ["is less than", "2"],
                    ["Absolute", "999"], ["before", "3"], ["between", "4"], ["after", "5"], 
                    ["Relative", "888"], ["before", "6"], ["between", "7"], ["after", "8"]]
      }
    },
    methods: {
      resetAvailableFilter() {
        let selected = [];
        $(`#${this.collection}-section .filter-dropdown`).each(function() {
          selected.push($(this).val());
        });
        this.availableFilter = this.FILTER_OPTIONS.filter(el => el[1] == "" || !(selected.indexOf(el[1]) > -1));
      },
      showNumberInput() {
        return (['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.filter.selectedFilter) > -1) || ((['last_order_date', 'first_order_date'].indexOf(this.filter.selectedFilter) > -1) && ["6", "7", "8"].indexOf(this.filter.selectedCondition) > -1)
      },
      showSecondInput() {
        return this.selectedFilter == "order_date" && (this.filter.selectedCondition == "4" || this.filter.selectedCondition == "7");
      },
      showOption(option) {
        return ((this.filter.selectedFilter == 'last_order_date' || this.filter.selectedFilter == 'first_order_date') && ["3", "4", "5", "6", "7", "8", "888", "999"].indexOf(option) > -1) || ((['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.filter.selectedFilter) > -1) && ["0", "1", "2"].indexOf(option) > -1)
      },
      removeFilter() {
        this.$emit('filterRemove', this.filter, this.collection, this.index);
      },
      filterChange() {
        this.$emit('filterChange', this.filter, this.collection, this.index);
      },
      detectFilter() {
        this.filter.selectedFilter = this.selectedFilter == "order_date" ? this.selectedDateOption + this.selectedFilter : this.selectedFilter;
        this.filterChange();
      },
      detectValue(type) {
        if (type == "date") {
          this.filter.dateValue = this.dateValue && this.dateValue0 ? `${this.dateValue}&${this.dateValue0}` : null;
        } else {
          this.filter.inputValue = this.inputValue && this.inputValue0 ? `${this.inputValue}&${this.inputValue0}` : null;
        }
        this.filterChange();
      },
      datePickerOptions() {
        return { from: this.dateValue0 };
      },
      datePickerOptions2() {
        return { to: this.dateValue };
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
