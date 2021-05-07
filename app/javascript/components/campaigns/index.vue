<template>
  <div class="campaign-tab">
    <div :class="'new-campaign-btn'">
      <button @click="onClickNewCampaign"> New Campaign </button>
    </div>
    <div class="campaign-tab-content">
      <div :class="'action'">
        <button v-on:click="duplicateCampaign" :disabled="selected.length > 1 || selected.length < 1"> Duplicate </button>
        <button v-on:click="deleteCampaigns"> Delete </button>
        <button v-on:click="exportCsv"> CSV </button>
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
            <th v-on:click="onSortByAlphabetically('sortByName', 'campaign_name')">
              Name
              <span>
                <font-awesome-icon icon="caret-down" v-if="sortByName"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th v-on:click="onSortByAlphabetically('sortByType', 'type')">
              Type
              <span>
                <font-awesome-icon icon="caret-down" v-if="sortByType"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th v-on:click="onSortByAlphabetically('sortByStatus', 'campaign_status')">
              Status
              <span>
                <font-awesome-icon icon="caret-down" v-if="sortByStatus"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>Monthly budget</th>
            <th v-on:click="onSortByAlphabetically('sortBySendDateStart', 'send_date_start')">
              Schedule
              <span>
                <font-awesome-icon icon="caret-down" v-if="sortBySendDateStart"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
          </tr>
          <tr v-for="item in thisCampaigns">
            <td>
              <input id="campaign-check-all" type="checkbox" v-model="selected" :value="item.id" number/>
            </td>
            <td>
              <span v-if="['Draft', 'Sent'].includes(item.campaign_status)">
                <md-switch v-model="campaignActive" class="md-primary" disabled></md-switch>
              </span>
              <span v-else>
                <md-switch v-model="campaignActive" :value="item.id" class="md-primary" @change="value => onChangeCampaignActive(value, item.id)"></md-switch>
              </span>
            </td>
            <td v-on:click="onEditCampaign(item.id)" class="campaign-name-style">{{ item.campaign_name }}</td>
            <td>{{ item.campaign_type }}</td>
            <td>{{ item.campaign_status}}</td>
            <td>
              <span class='t-b'> {{ item.budget }}</span>
            </td>
            <td>
              <span class='t-b'> {{ item.schedule }}</span>
              <span v-if="item.campaign_status == 'Draft'" style="font-size: 10px">Sending on</span>
            </td>
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
    </div>
</template>

<script>
  /* global Turbolinks */
  import Vue from 'vue/dist/vue.esm'
  import axios from 'axios'
  import DropdownMenu from './dropdown_menu.vue'
  import { MdSwitch } from 'vue-material/dist/components'
  import _ from 'lodash'

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
        campaignActive: [],
        campaignType: ['Automation', 'One-off'],
        sortBy: ['sortByName', 'sortByType'],
        sortByName: true,
        sortByType: true,
        sortByStatus: true,
        sortBySendDateStart: true
      }
    },

    created() {
      this.listcampaignActive()
    },

    computed: {

      disablePauseToggle: function (){
        if(['draft', 'sent'].includes(campaign.id)){
          return true
        }
        return false;
      },

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
      },
    },

    watch: {
      thisCampaigns: function(){
        this.listcampaignActive()
      },
    },

    methods: {
      onSortByAlphabetically: function(sortby, name){
        if(this[sortby]){
          this[sortby] = false
          this.thisCampaigns = _.orderBy(this.thisCampaigns, name, 'desc')
        } else {
          this[sortby] = true
          this.thisCampaigns = _.orderBy(this.thisCampaigns, name, 'asc')
        }
      },

      onEditCampaign: function(id) {
        Turbolinks.visit(`/automations/${id}/edit`);
      },

      duplicateCampaign: function() {
        if(confirm('Are you sure?')){
          let _this = this
          axios.get('/campaigns/duplicate_campaign.json', { params: { campaign_id: this.selected } })
            .then(function(response) {
              _this.updateState(response.data)
            }).catch(function (error) {
          });
        }
      },

      onClickNewCampaign: function() {
        axios.get('/automations/new.json', {})
          .then(function(response) {
            console.log(response);
            Turbolinks.visit(`/automations/${response.data.id}/edit`);
          }).catch(function (error) {
        });
      },

      exportCsv: function(){
        let target = `/campaigns/export_csv.json`;
        axios.get(target, {})
          .then(function(response) {
            const url = window.URL.createObjectURL(new Blob([JSON.parse(response.data.csv_data)]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', response.data.filename); //or any other extension
            document.body.appendChild(link);
            link.click();
          }).catch(function (error) {
        });
      },

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
  .campaign-tab-content {
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

    &:disabled{
      border: 1px solid #999999;
      background-color: #cccccc;
      color: #666666;
    }
  }

  .campaign-dashboard {
    width: 100%;
    .md-switch{
      margin: 16px 0;
    }
  }

  .new-campaign-btn{
    text-align: right;
    margin-bottom: 5px;
    button{
      font-size: 16px;
      border: 1px solid #9900ff;
      background: #9900ff;
      color: white;
    }
  }

  .campaign-dashboard, .campaign-dashboard th, .campaign-dashboard td {
    border-collapse: collapse;
    text-align: center;
    border-bottom: 1px solid #ddd;
    th {
      cursor: pointer;
      padding: 16px 0;
    }
  }

  .campaign-name-style{
    color: #6baafc;
    cursor: pointer;
    text-decoration: underline;
  }

  .action{
    display: flex;
    margin-bottom: 10px;
    button{
      margin-right: 10px;
    }
  }

  .t-b {
    display: block;
    margin: 3px;
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