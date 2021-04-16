<template>
  <div class="campaign-tab">
    <div :class="'action'">
      <button> Duplicate </button>
      <button v-on:click="deleteCampaigns"> Delete </button>
      <button> CSV </button>
      <DropdownMenu :campaignTypes="campaignTypes" :campaignStatuses="campaignStatuses" ref="DropdownMenu"></DropdownMenu>
      <input :placeholder="'Search'" v-model="searchQuery" @input="debounceSearch" />
    </div>
    <div>
      <table class="campaign-dashboard">
        <tr>
          <th>
            <input id="campaign-check-all" type="checkbox" v-model="selectAll"/>
          </th>
          <th></th>
          <th>Name</th>
          <th>Type</th>
          <th>Status</th>
          <th>Budget</th>
          <th>Schedule</th>
        </tr>
        <tr v-for="item in thisCampaigns">
          <td>
            <input id="campaign-check-all" type="checkbox" v-model="selected" :value="item.id" number/>
          </td>
          <td>
            <md-switch v-model="campaignActive" :value="item.id" class="md-primary" @change="value => onChangeCampaignActive(value, item.id)"></md-switch>
          </td>
          <td>{{ item.name }}</td>
          <td>{{ item.type }}</td>
          <td>{{ campaignStatus(item.enabled) }}</td>
          <td>{{ item.budget }}</td>
          <td>{{ item.schedule }}</td>
        </tr>
      </table>
    </div>
    <paginate
      v-model="currentPage"
      :page-count="thisTotalPages"
      :click-handler="changePagination"
      :prev-text="'Prev'"
      :next-text="'Next'"
      :container-class="'pagination'"
      :page-class="'page-item'">
    </paginate>


  </div>
</template>

<script>
  /* global Turbolinks */
  import Vue from 'vue/dist/vue.esm'
  import axios from 'axios'
  import DropdownMenu from './dropdown_menu.vue'
  import { MdSwitch } from 'vue-material/dist/components'

  Vue.use(MdSwitch)

  export default {
    components: {
      DropdownMenu
    },
    props: {
      campaigns: {
        type: Array,
        required: true
      },
      totalPages: {
        type: Number,
        required: true
      },
      campaignStatuses: {
        type: Array,
        required: true
      },
      campaignTypes: {
        type: Array,
        required: true
      },
    },

    data: function() {
       return {
        thisCampaigns: this.campaigns,
        name: "Post sale card",
        selected: [],
        thisTotalPages: this.totalPages,
        currentPage: 1,
        searchQuery: null,
        debounce: null,
        campaignActive: []
      }
    },

    created() {
      this.listcampaignActive()
    },

    computed: {
      selectAll: {
        get() {
          if (this.thisCampaigns && this.thisCampaigns.length > 0) {
            let allChecked = true;

            for (const campaign of this.thisCampaigns) {
              if (!this.selected.includes(campaign.id)) {
                allChecked = false;
              }
              if(!allChecked) break;
            }

            return allChecked;
          }

          return false;
        },

        set(value) {
          const checked = [];
          if (value) {
            this.thisCampaigns.forEach((campaign) => {
              checked.push(campaign.id);
            });
          }

          this.selected = checked;
        }
      }
    },

    watch: {
      thisCampaigns: function(){
        this.listcampaignActive()
      },
    },


    methods: {
      onChangeCampaignActive: function(event, campaign_id){
        let _this = this
        let target = `/automations/${campaign_id}.json`;
        let campaign = this.thisCampaigns.find(function(campaign){
          return campaign.id == campaign_id
        });
        let index = this.thisCampaigns.indexOf(campaign)
        axios.put(target, { card_order: {enabled: campaign.enabled ? false : true} })
          .then(function(response) {
            _this.thisCampaigns[index] = JSON.parse(response.data.campaign)
            _this.$forceUpdate();
          }).catch(function (error) {
        });

      },

      listcampaignActive: function() {
        let list = []
        this.thisCampaigns.forEach((campaign) => {
          if(campaign.enabled){
            list.push(campaign.id);
          }
        });
        this.campaignActive = list
      },

      debounceSearch(event) {
        this.message = null
        clearTimeout(this.debounce)
        this.debounce = setTimeout(() => {
          this.searchQuery = event.target.value
          this.onSearchQuery()
          console.log(this.searchQuery)
        }, 600)
      },

      onSearchQuery: function(){
        let _this = this
        let target = `/campaigns.json`;
        axios.get(target, { params: {query: this.getParamsQuery(), filters: this.collectParamsFilters()} })
          .then(function(response) {
            _this.updateState(response.data)
          }).catch(function (error) {
        });
      },

      campaignStatus: function(enabled){
        if (enabled) {
          return "Sending"
        } else {
          return "Paused"
        }
      },

      changePagination: function(pageNum){
        let _this = this
        let target = `/campaigns.json`;
        axios.get(target, { params: {page: pageNum, query: this.getParamsQuery(), filters: this.collectParamsFilters()} })
          .then(function(response) {
            _this.updateState(response.data, false)
          }).catch(function (error) {
        });
      },

      deleteCampaigns: function() {
        if(confirm('Are you sure?')){
          let _this = this
          let target = `/campaigns/delete_campaigns.json`;
          let campaignsSelected = this.selected
          axios.delete(target, { params: {campaign_ids: campaignsSelected} })
            .then(function(response) {
              _this.updateState(response.data)
            }).catch(function (error) {
          });
        }
      },

      collectParamsFilters: function() {
        return this.$refs.DropdownMenu.collectParamsFilters()
      },

      getParamsQuery: function() {
        return this.searchQuery ? this.searchQuery.toLocaleLowerCase() : ""
      },

      updateState: function(data, willReturnToFisrtPage=true) {
        this.thisCampaigns = JSON.parse(data.campaigns)
        this.thisTotalPages = data.total_pages
        this.selected = []
        if(willReturnToFisrtPage){
          this.currentPage = 1
        }
      }
    },
  }

</script>
<style lang="scss">
  .campaign-tab {
    background: white;
    padding: 10px 10px;
    box-shadow: 5px 10px 4px 0px rgba(0, 0, 0, 0.14);
    border: 1px solid rgba(0, 0, 0, 0.12);
  }

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

  .campaign-dashboard {

    width: 100%;
    .md-switch{
      margin: 16px 0;
    }
  }

  .campaign-dashboard, .campaign-dashboard th, .campaign-dashboard td {
    border-collapse: collapse;
    text-align: center;
    border-bottom: 1px solid #ddd;
    th {
      padding: 16px 0;
    }
  }

  .action{
    display: flex;
    margin-bottom: 10px;
    button{
      margin-right: 10px;
    }
  }

  .pagination{
    display: flex;
    justify-content: center;
    list-style: none;
    li{
      padding: 5px;
      &.active{
        background: darkgray;
      }
      &.disabled{
        color: gray;
      }
      a:focus{
        outline: none;
        box-shadow: none;
      }
    }
  }
</style>