<template>
  <div class="filter-line">
    <select class="filter-dropdown" v-model="selectedFilter">
      <option v-for="option in FILTER_OPTIONS" :key="option[1]" :value="option[1]">{{option[0]}}</option>
    </select>
    <select class="option-dropdown" v-if="selectedFilter != ''" v-model="selectedCondition">
      <option v-for="condition in CONDITIONS" v-if="showOption(condition[1])" :key="condition[1]" :value="condition[1]">{{condition[0]}}</option>
    </select>
    <datepicker class="valueInput" v-model="dateValue" v-if="selectedFilter != '' && !showNumberInput()" />
    <input type="number" class="valueInput" v-model="inputValue" v-if="showNumberInput()" />
    <div class="dropdown">
      <button type="button" class="more-action-btn" v-if="selectedFilter != ''">...</button>
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
    data() {
      return {
        FILTER_OPTIONS: [["Select a filter" , ""              ],
                         ["Number of orders", "number_of_order" ],
                         ["Total Spend"     , "total_spend"     ],
                         ["Last order date" , "last_order_date" ],
                         ["First order date", "first_order_date"],
                         ["Last order total", "last_order_total"]
                        ],
        CONDITIONS: [["is", 0], ["is greater than", 1], ["is less than", 2],
              ["before", 3], ["between", 4], ["after", 5], ["before", 6],
              ["between", 7], ["after", 8]],
        selectedFilter: "",
        selectedCondition: 0,
        dateValue: null,
        inputValue: null,
      }
    },
    methods: {
      showNumberInput() {
        return (['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.selectedFilter) > -1) || ((['last_order_date', 'first_order_date'].indexOf(this.selectedFilter) > -1) && [6, 7, 8].indexOf(this.selectedCondition) > -1)
      },
      showOption(option) {
        return ((this.selectedFilter == 'last_order_date' || this.selectedFilter == 'first_order_date') && [3, 4, 5, 6, 7, 8].indexOf(option) > -1) || ((['number_of_order', 'total_spend', 'last_order_total'].indexOf(this.selectedFilter) > -1) && [0, 1, 2].indexOf(option) > -1)
      },
      removeFilter() {
        $(this.$el).parent().remove();
      }
    }
  }
</script>
<style scoped>
.filter-line {
  width: 600px;
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
  width: 254px;
  margin-right: 4px;
  height: 30px;
}

.more-action-btn {
  transform: rotate(90deg);
  border: none;
  background: none;
  font-size: 20px;
  font-weight: bold;
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
</style>
