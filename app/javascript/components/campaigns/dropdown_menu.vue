<template>
  <div class="dropdown-btn">
    <button @click="isOpen = !isOpen" >
      Filters
      <font-awesome-icon icon="caret-down"/>
    </button>
    <div class="dropdown-list" v-if="isOpen">
      <div class="filter-items">
        <span>Type</span>
        <select v-model="filters.type">
          <option v-for="item in campaignTypes" :value="item">{{ item }}</option>
        </select>
      </div>
      <div class="filter-items">
        <span>Status</span>
        <select v-model="filters.status" @change="addStatus">
          <option v-for="item in availableStatus" :value="item">{{ item }}</option>
        </select>
      </div>
      <div class="filter-items">
        <span>Date Created</span>
        <select v-model="filters.dateCreated">
          <option value="Any">Any</option>
          <option value="Pickdate">Pickdate</option>
        </select>
      </div>
      <div v-if="filters.dateCreated == 'Pickdate'">
        <date-picker 
          v-model="range" 
          type="date" 
          range placeholder="Select date range" 
          range-separator=" - " 
          format="MM-DD-YYYY" 
          :disabled-date="disableAfterToday"
          id="date-picker"
        >
        </date-picker>
      </div>
      <div class="filter-items">
        <button v-model="filters.clearAll" @click="onResetFilter" class="margin-0 full-width">Clear all filters</button>
      </div>
      <div class="filter-items">
        <button @click="closeFilters" class="full-width">Cancel</button>
        <button @click="submitFilters" class="full-width margin-0">Save</button>
      </div>
      <div v-if="selectedStatuses.length > 0">
        <md-divider></md-divider>
        <md-subheader>Status</md-subheader>
        <md-chip md-deletable v-for="item in selectedStatuses"  @md-delete="removeStatus(item)">{{ item }}</md-chip>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import DatePicker from 'vue2-datepicker';
import 'vue2-datepicker/index.css';

export default {
  name: 'dropdownMenu',
  components: {
    DatePicker
  },
  created() {
    window.addEventListener('click', this.checkClickOn);
  },
  data() {
    return {
      isOpen: false,
      date: new Date(),
      filters: {
        type: "Any",
        status: "Any",
        dateCreated: "Any",
        clearAll: false,
      },
      campaignTypes: ['Any', 'Automation', 'One-off'],
      availableStatus: ['Any', 'Processing', 'Scheduled', 'Sending', 'Sent', 'Paused', 'Draft', 'Out of credit', 'Error'],
      selectedStatuses: [],
      isDisable: true,
      range: []
    };
  },
  methods: {
    checkClickOn(event) {
      if (document.getElementById(this.id) && !document.getElementById(this.id).contains(event.target)) {
        this.isOpen = false;
      }
    },

    submitFilters: function() {
      let target = `/campaigns.json`;
      let _this = this
      axios.get(target,
        {
          params: {
            query: _this.$parent.getParamsQuery(),
            filters: this.collectParamsFilters(),
          }
        }
      ).then(function(response) {
          _this.$parent.updateState(response.data, true);
          _this.closeFilters();
        }).catch(function (error) {
      });


    },

    collectParamsFilters: function() {
      if(this.filters.dateCreated == "Pickdate") {
        return {
          type: this.filters.type,
          status: this.filters.status,
          created_at: this.range[0],
          date_completed: this.range[1]
        }  
      } else {
        return {
          type: this.filters.type,
          status: this.filters.status,
          date: "Any"
        }
      }
      
    },

    closeFilters: function() {
      this.isOpen = false;
    },

    onResetFilter: function() {
      this.filters = {
        type: "Any",
        status: "Any",
        dateCreated: "Any",
        clearAll: false,
      }
      this.range = []
    },

    disableAfterToday: function(date) {
      const today = new Date()
      today.setHours(0, 0, 0, 0);
      return date > today
    },

    removeStatus: function(status) {
      this.selectedStatuses = this.selectedStatuses.filter(element => element != status)
    },

    addStatus: function() {
      if(this.filters.status == "Any") return
      this.availableStatus = this.availableStatus.filter(function(element) {
        return (element != this.filters.status && element != "Any") ? true : false
      },this)
      this.selectedStatuses.push(this.filters.status)
      console.log(this.availableStatus)
    }
  }
};
</script>

<style lang="scss" scoped>

.dropdown-btn{
  .margin-0{
    margin: 0
  }
  .full-width{
    width: 100%
  }
}

.dropdown {
  position: relative;
  width: fit-content;
  &-list {
    padding: 15px;
    background: white;
    margin-top: 5px;
    position: absolute;
    z-index: 10;
    border: 1px solid black;
    border-radius: 4px;
    .filter-items{
      display: flex;
      margin-bottom: 5px;
      span {
        display: inline-block;
        width: 120px;
      }
      select {
        width: 158px;
      }
    }
  }
}

#date-picker {
  margin-bottom: 5px;
}

</style>