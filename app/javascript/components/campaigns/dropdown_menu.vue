<template>
  <div>
    <button @click="isOpen = !isOpen" >Filters</button>
    <div class="dropdown-list" v-if="isOpen">
      <div class="filter-items">
        <span>Type</span>
        <select v-model="filters.type">
          <option v-for="item in campaignTypes">{{ item }}</option>
        </select>
      </div>
      <div class="filter-items">
        <span>Status</span>
        <select v-model="filters.status">
          <option v-for="item in campaignStatuses">{{ item }}</option>
        </select>
      </div>
      <div class="filter-items">
        <span>Date Created</span>
        <datepicker v-model="filters.dateCreated"></datepicker>
      </div>
      <div class="filter-items">
        <span>Date Completed</span>
        <datepicker v-model="filters.dateCompleted"></datepicker>
      </div>
      <div class="filter-items">
        <button v-model="filters.clearAll" @click="onResetFilter" class="full-width">All</button>
      </div>
      <div class="filter-items">
        <button @click="closeFilters" class="full-width">Cancel</button>
        <button @click="submitFilters" class="full-width">Save</button>
      </div>
    </div>
  </div>
</template>

<script>
import Datepicker from 'vuejs-datepicker';
import axios from 'axios'

export default {
  name: 'dropdownMenu',
  components: {
    Datepicker
  },
  created() {
    window.addEventListener('click', this.checkClickOn);
  },
  props: ['campaignTypes', 'campaignStatuses'],
  data() {
    return {
      isOpen: false,
      date: new Date(),
      filters: {
        type: "",
        status: "",
        dateCreated: "",
        dateCompleted: "",
        clearAll: false,
      }
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
      return {
        type: this.filters.type,
        status: this.filters.status,
        created_at: this.filters.dateCreated,
        date_completed: this.filters.dateCompleted
      }
    },

    closeFilters: function() {
      this.isOpen = false;
    },

    onResetFilter: function() {
      this.filters = {
        type: "",
        status: "",
        dateCreated: "",
        dateCompleted: "",
        clearAll: false,
      }
    }
  }
};
</script>

<style lang="scss" scoped>
button {
  position: relative;
  padding: 10px 20px;
  background-color: white;
  border: 1px solid black;
  cursor: pointer;
  transition: 0.3s;
  &:focus {
    outline: 0px;
  }
  &:hover {
    background: #000;
    color: white;
  }
  &.isActive {
    background: #000;
    color: white;
  }
  .full-width {
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
</style>