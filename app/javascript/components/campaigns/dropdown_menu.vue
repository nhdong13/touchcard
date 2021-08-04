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
        <select v-model="filters.status" @change="selectStatus">
          <option v-for="item in availableStatus" :value="item.content" :class="[item.isHidden ? 'd-none' : '']">{{ item.content }}</option>
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
import _ from 'lodash';

export default {
  name: 'dropdownMenu',
  components: {
    DatePicker
  },
  created() {
    window.addEventListener('click', this.checkClickOn);
    this.loadFilterSettings()
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
      availableStatus: [{
        content: 'Any',
        isHidden: false
      }, {
        content: 'Processing',
        isHidden: false
      }, {
        content: 'Scheduled',
        isHidden: false
      }, {
        content: 'Sending',
        isHidden: false
      }, {
        content: 'Complete',
        isHidden: false
      }, {
        content: 'Paused',
        isHidden: false
      }, {
        content: 'Draft',
        isHidden: false
      }, {
        content: 'Out of credit',
        isHidden: false
      }, {
        content: 'Error',
        isHidden: false
      }],
      selectedStatuses: [],
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
      let _this = this
      axios.patch(`/settings/campaign_filter_option.json`,
      {
        filters: this.collectParamsFilters()
      }).then(function(response) {
        axios.get(`/campaigns.json`,
          {
            params: {
              query: _this.$parent.getParamsQuery(),
              // filters: _this.collectParamsFilters()
            }
          }
        ).then(function(response) {
            _this.$parent.updateState(response.data, true);
            _this.closeFilters();
          }).catch(function (error) {
            console.log(error)
          });
      }).catch(function(error) {
        console.log(error)
      })


    },

    collectParamsFilters: function() {
      return {
        type: this.filters.type,
        status: this.selectedStatuses.length > 0 ? this.selectedStatuses : [],
        dateCreated: (this.filters.dateCreated == "Pickdate") ? { created_at: this.range[0], date_completed: this.range[1] } : {},
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
      this.selectedStatuses = []
      for (var i = 0; i < this.availableStatus.length; i++) {
        this.availableStatus[i].isHidden = false
      }
    },

    disableAfterToday: function(date) {
      const today = new Date()
      today.setHours(0, 0, 0, 0);
      return date > today
    },

    removeStatus: function(status) {
      this.selectedStatuses = this.selectedStatuses.filter(element => element != status)
      this.availableStatus.find(element => element.content == status).isHidden = false
    },

    selectStatus: function() {
      if(this.filters.status == "Any") {
        for (var i = 0; i < this.availableStatus.length; i++) {
          this.availableStatus[i].isHidden = false
        }
        this.selectedStatuses = []  
        return
      }
      this.availableStatus.find(element => element.content == this.filters.status).isHidden = true
      this.selectedStatuses.push(this.filters.status)
    },

    loadFilterSettings: function() {
      let _this = this
      axios.get(`/settings/campaign_filter_option.json`).then(function(response) {
        const filterSetting = response.data.filter
        _this.filters.type = _.isEmpty(filterSetting.type) ? "Any" : filterSetting.type
        if(_.isEmpty(filterSetting.status)) {
          _this.filters.status = "Any"
        } else {
          for (var i = 0; i < filterSetting.status.length; i++) {
            _this.filters.status = filterSetting.status[i]
            _this.selectStatus()
          }
        }
        if(_.isEmpty(filterSetting.dateCreated) || _.isEmpty(filterSetting.dateCreated.created_at) || _.isEmpty(filterSetting.dateCreated.date_completed)) {
          _this.filters.dateCreated = "Any"
        } else {
          _this.filters.dateCreated = "Pickdate"
          _this.range.push(new Date(filterSetting.dateCreated.created_at))
          _this.range.push(new Date(filterSetting.dateCreated.date_completed))
        }
      }).catch(function(error) {
        if(!_.isEmpty(error)) console.log(error)
      })
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
    max-width: 400px;
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

.d-none {
  display: none;
}

</style>