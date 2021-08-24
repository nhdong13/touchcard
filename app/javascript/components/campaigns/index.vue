<template>
  <div class="campaign-tab">
    <div :class="'new-campaign-btn'">
      <button @click="onClickNewCampaign" class="mdc-button mdc-button--raised"> New Campaign </button>
    </div>
    <div class="campaign-tab-content">
      <div :class="'action'">
        <div :class="'action'">
          <button v-on:click="showModalConfirmDuplicate" :disabled="selected.length > 1 || selected.length < 1" class="mdc-button mdc-button--stroked"> Duplicate </button>
          <button v-on:click="showModalConfirmDeleteCampaign" :disabled="selected.length < 1" class="mdc-button mdc-button--stroked"> Delete </button>
        </div>
        <div :class="'search-action'">
          <!-- <button v-on:click="exportCsv">
            CSV
            <font-awesome-icon icon="long-arrow-alt-down"/>
           </button> -->
          <!-- <DropdownMenu ref="DropdownMenu"></DropdownMenu> -->
          <input :placeholder="'SEARCH'" v-model="searchQuery" @input="debounceSearch" class="border-theme"/>
        </div>
      </div>
      <div v-if="$screen.width > 425">
        <table class="campaign-dashboard">
          <tr>
            <th width="35px">
              <input id="campaign-check-all" type="checkbox" v-model="selectAll"/>
            </th>
            <th></th>
            <th>Design</th>
            <th class="mw-col">
              Name
              <span v-on:click="onSortByAlphabetically('sortByName', 'campaign_name')">
                <font-awesome-icon icon="caret-down" v-if="sortByName"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>
              Status
              <span v-on:click="onSortByAlphabetically('sortByStatus', 'campaign_status')">
                <font-awesome-icon icon="caret-down" v-if="sortByStatus"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>
              Type
              <span v-on:click="onSortByAlphabetically('sortByType', 'campaign_type')">
                <font-awesome-icon icon="caret-down" v-if="sortByType"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>
              Budget
              <span v-on:click="onSortByAlphabetically('sortByMonthlyBudget', 'budget')">
                <font-awesome-icon icon="caret-down" v-if="sortByMonthlyBudget"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>
              Starts
              <span v-on:click="onSortByAlphabetically('sortBySendDateStart', 'send_date_start')">
                <font-awesome-icon icon="caret-down" v-if="sortBySendDateStart"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th>
              Ends
              <span v-on:click="onSortByAlphabetically('sortBySendDateEnd', 'send_date_end')">
                <font-awesome-icon icon="caret-down" v-if="sortBySendDateEnd"/>
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
          </tr>
          <tr v-for="item in thisCampaigns">
            <td class="checkbox-cell">
              <input type="checkbox" v-model="selected" :value="item.id" number/>
            </td>
            <td>
              <span v-if="['Out of credit', 'Error', 'Draft', 'Complete'].includes(item.campaign_status)">
                <md-switch v-model="campaignActive" class="md-primary" disabled></md-switch>
              </span>
              <span v-else>
                <md-switch v-model="campaignActive" :value="item.id" class="md-primary" @change="value => onChangeCampaignActive(value, item.id)" :disabled="disableToggle(item)"></md-switch>
              </span>
            </td>
            <td>
              <!--
                key attribute is used to make Vue re-render PreviewImage component when the campaign is changed
              -->
              <PreviewImage
                :key="item.id"
                :front-image="item.front_json.background_url"
                :back-image="item.back_json.background_url"
              />
            </td>
            <!-- The maximum of character to display is 45 -->
            <td>
              <span v-on:click="onEditCampaign(item.id)" class="campaign-name-style two-line-text">{{ item.campaign_name | truncate(45) }}</span>
            </td>
            <td>{{ item.campaign_status}}</td>
            <td>{{ item.campaign_type }}</td>
            <td>
              <span class='t-b'> {{ item.campaign_type == "Automation" && item.budget != "-" ? item.budget + '/month' : item.budget }}</span>
            </td>
            <td>
              <span class='t-b'> {{ splitedSchedule(item.schedule)[0] }}</span>
            </td>
            <td>
              <span class='t-b'> {{ splitedSchedule(item.schedule)[1] }}</span>
            </td>
          </tr>
        </table>
      </div>
      <div class="mobile-support" v-else>
        <ul>
          <li class="d-flex" v-for="item in thisCampaigns">
            <span class="d-flex ml-5">
              <PreviewImage
                :key="item.id"
                :front-image="item.front_json.background_url"
                :back-image="item.back_json.background_url"
              />
            </span>
            <span class="campaign-info d-flex flex-column">
              <div class="campaign-name">
                <span v-on:click="onEditCampaign(item.id)" class="campaign-name-style two-line-text">{{ item.campaign_name | truncate(30) }}</span>
                <span v-if="['Out of credit', 'Error', 'Draft', 'Complete'].includes(item.campaign_status)" class="toggle-button">
                  <md-switch v-model="campaignActive" class="md-primary" disabled></md-switch>
                </span>
                <span class="toggle-button" v-else>
                  <md-switch v-model="campaignActive" :value="item.id" class="md-primary" @change="value => onChangeCampaignActive(value, item.id)" :disabled="disableToggle(item)"></md-switch>
                </span>
              </div>
              <div class="campaign-detail d-flex">
                <div class='column-info flex-column d-flex'>
                  <strong>Status</strong>
                  <span>{{ item.campaign_status}}</span>
                </div>
                <div class='column-info flex-column d-flex'>
                  <strong>Type</strong>
                  <span>{{ item.campaign_type}}</span>
                </div>
                <div class='column-info flex-column d-flex'>
                  <strong>Budget</strong>
                  <span>{{ item.budget}}</span>
                </div>
                <div class='column-info flex-column d-flex'>
                  <strong>Starts</strong>
                  <span>{{ splitedSchedule(item.schedule)[0] }}</span>
                </div>
                <div class='column-info flex-column d-flex'>
                  <strong>Ends</strong>
                  <span>{{ splitedSchedule(item.schedule)[1] }}</span>
                </div>
              </div>
            </span>
          </li>
        </ul>
      </div>
      <div id="pagination">
        <CustomePagination
          v-model="currentPage"
          :total-page="thisTotalPages"
          :page-range="5"
          :container-class="'pagination'"
          :page-class="'page-item'"
          :click-handler="changePagination"
          :key="currentPage"
        > 
        </CustomePagination>
      </div>
    </div>
      <campaignModal name="duplicateModal" :classes="'duplicate-modal'" :width="450" :height="200" :clickToClose="false">
        <div>
          <div>
            <strong><h3>What do you want to name this campaign?</h3></strong>
          </div>
          <div>
            <input id="campaign_name" v-model="duplicateCampaignName" class="border-theme">
          </div>
          <br/>
          <div>
            <button v-on:click="closeModalConfirmDuplicateCampaign" class="mdc-button mdc-button--stroked"> Cancel </button>
            <button v-on:click="duplicateCampaign" class="mdc-button mdc-button--stroked"> Save </button>
          </div>
        </div>
      </campaignModal>

      <campaignModal name="deleteCampaignModal" :classes="'delete-campaign-modal'" :width="450" :height="200" :clickToClose="false">
        <div>
          <div>
            <strong><h3>This action cannot be undone. Are you sure you want to delete the campaign(s)?</h3></strong>
          </div>
          <div>
            <button v-on:click="closeModalConfirmDeleteCampaign" class="mdc-button mdc-button--stroked"> Cancel </button>
            <button v-on:click="deleteCampaigns" class="mdc-button mdc-button--stroked"> Delete </button>
          </div>
        </div>
      </campaignModal>
    </div>
</template>

<script>
  /* global Turbolinks */
  import Vue from 'vue/dist/vue.esm'
  import axios from 'axios'
  import DropdownMenu from './dropdown_menu.vue'
  import { MdSwitch } from 'vue-material/dist/components'
  import _ from 'lodash'
  import VModal from 'vue-js-modal'
  import CustomePagination from './pagination.vue'
  import PreviewImage from './campaign_index_preview_image.vue'
  import { dateFormat, formatDateCampaign } from 'packs/date-format.js'
  import { MAXIMUM_CAMPAIGN_NAME_LENGTH } from '../../config.js'

  Vue.use(VModal, { componentName: 'campaignModal'})
  Vue.use(MdSwitch)

  export default {
    components: {
      DropdownMenu,
      CustomePagination,
      PreviewImage
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
      shared: {
        type: Object
      }
    },
    mounted () {
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
        sortBy: ['sortByName', 'sortByType'],
        sortByName: true,
        sortByType: true,
        sortByStatus: true,
        sortBySendDateStart: true,
        sortBySendDateEnd: true,
        sortByMonthlyBudget: true,
        duplicateCampaignName: "",
      }
    },

    created() {
      this.listcampaignActive()
      // TODO: comment this piece of code
      if(!_.isEmpty(this.shared.campaign)) {
          const _sharedState = this.shared.campaign
          let targetCampaignId = this.thisCampaigns.findIndex(obj => {
            return obj.id == _sharedState.id
          })
          if(targetCampaignId != -1) {
            const startDate = dateFormat(this.shared.campaign.send_date_start, "mediumDate")
            const endDate = this.shared.campaign.send_date_end ? dateFormat(this.shared.campaign.send_date_end, "mediumDate") : "Ongoing"
            this.shared.campaign.schedule = `${startDate} - ${endDate}`
            this.shared.campaign.campaign_status = this.shared.campaign.campaign_status.split("_").join(" ").replace(/^\w/, (c) => c.toUpperCase())
            this.shared.campaign.campaign_type = this.shared.campaign.campaign_type.split("_").join(" ").replace(/^\w/, (c) => c.toUpperCase())

            if(this.shared.campaign.campaign_type == "One off") {
              this.shared.campaign.budget = "-"
            } else {
              if(this.shared.campaign.budget_type == "monthly") this.shared.campaign.budget = `$${this.shared.campaign.budget_update}`
              else this.shared.campaign.budget = "-"
            }

            if(this.shared.campaign.campaign_status == "Processing") this.campaignActive.push(this.shared.campaign.id)
            this.thisCampaigns[targetCampaignId] = this.shared.campaign
            this.shared.campaign = null
            this.changePagination(this.currentPage)
          }
        }
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
      },
    },

    watch: {
      thisCampaigns: function(){
        this.listcampaignActive()
      }
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


      showModalConfirmDuplicate: function() {
        const selectedCampaignName = this.thisCampaigns.find(campaign => campaign.id == this.selected).campaign_name
        this.duplicateCampaignName = "Copy of " + selectedCampaignName;
        if(this.duplicateCampaignName.length > MAXIMUM_CAMPAIGN_NAME_LENGTH) {
          this.duplicateCampaignName = selectedCampaignName;
        }
        this.$modal.show('duplicateModal')
      },

      closeModalConfirmDuplicateCampaign: function() {
        this.$modal.hide('duplicateModal')
      },

      showModalConfirmDeleteCampaign: function() {
        this.$modal.show('deleteCampaignModal')
      },

      closeModalConfirmDeleteCampaign: function() {
        this.$modal.hide('deleteCampaignModal')
      },


      duplicateCampaign: function() {
        let _this = this
        axios.get('/campaigns/duplicate_campaign.json', { params: { campaign_id: this.selected, campaign_name: this.duplicateCampaignName } })
          .then(function(response) {
            _this.updateState(response.data)
            _this.closeModalConfirmDuplicateCampaign()
          }).catch(function (error) {
        });
      },

      onClickNewCampaign: function() {
        Turbolinks.visit(`/automations/new`);
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

      changePagination: function(pageNum){
        let _this = this
        let target = `/campaigns.json`;
        this.currentPage = pageNum;
        axios.get(target, { params: {page: pageNum, query: this.getParamsQuery(), filters: this.collectParamsFilters()} })
          .then(function(response) {
            _this.updateState(response.data, false)
          }).catch(function (error) {
        });
      },

      deleteCampaigns: function() {
        let _this = this
        let target = `/campaigns/delete_campaigns.json`;
        let campaignsSelected = this.selected
        axios.delete(target, { params: {campaign_ids: campaignsSelected, page: this.currentPage, query: this.getParamsQuery(), filters: this.collectParamsFilters()} })
          .then(function(response) {
            _this.updateState(response.data, false)
            _this.closeModalConfirmDeleteCampaign()
          }).catch(function (error) {
        });
      },

      collectParamsFilters: function() {
        // return this.$refs.DropdownMenu.collectParamsFilters()
        return null
      },

      getParamsQuery: function() {
        return this.searchQuery ? this.searchQuery.toLocaleLowerCase() : ""
      },

      updateState: function(data, willReturnToFisrtPage=true) {
        let tmp_campaigns = JSON.parse(data.campaigns)
        tmp_campaigns.forEach(campaign => {
          campaign.schedule = formatDateCampaign(campaign.send_date_start, campaign.send_date_end, campaign.campaign_type)
        })

        this.thisCampaigns = tmp_campaigns
        this.thisTotalPages = data.total_pages
        this.selected = []
        if(willReturnToFisrtPage){
          this.currentPage = 1
        }
      },

      selectCampaign: function(e) {
        if(_.isEmpty(e.target.children[0])) return
        const campaignId = Number(e.target.children[0].defaultValue)
        if(e.target.children[0].checked) {
          e.target.children[0].checked = false
          this.selected = this.selected.filter(element => element != campaignId)
        } else {
          e.target.children[0].checked = true
          this.selected.push(campaignId)
        }
      },

      // User can't interact with toggle when campaign is in status sending and have type one-off
      disableToggle: function(campaign) {
        if(campaign.campaign_type == "One-off" && campaign.campaign_status == "Sending") true
        return false
      },

      splitedSchedule(schedule) {
        if (schedule == "Not set") {
          return ["Not set", "Not set"];
        } else if (schedule.includes(" - ")) {
          return [schedule.split(" - ")[0], schedule.split(" - ")[1]];
        } else {
          return [schedule, ""]
        }
      }
    },

    filters: {
      truncate: function(data, num) {
        if(_.isEmpty(data)) return data
        const truncatedStr = []
        let characterCount = 0
        data.split(" ").slice(0, data.length).forEach((element) => {
          if((element.length + characterCount) < num) {
            truncatedStr.push(element)
            characterCount += (element.length + 1) // 1 is for space " "
          }
        })
        let result = truncatedStr.join(" ")
        if(data != result) result += " ..."
        return result
      }
    }
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
  }

  .campaign-dashboard, .campaign-dashboard th, .campaign-dashboard td {
    border-collapse: collapse;
    text-align: left;
    border-bottom: none;//1px solid #ddd;
    th {
      padding: 16px 0;
    }
    th span{
      cursor: pointer;
    }
  }

  .campaign-name-style{
    color: #6baafc;
    cursor: pointer;
    text-decoration: underline;
  }

  .action{
    display: flex;
    button{
      margin-right: 10px;
    }
  }

  .search-action{
    display: flex;
    margin-left: auto;
  }

  .t-b {
    display: block;
    margin: 3px;
  }

  #pagination .page-item {
    display: inline-block;
  }

  #pagination .pagination{
    text-align: center;
    list-style: none;
    li{
      padding: 5px;
      &.active{
        background: #f4f4f4;
      }
      &.disabled{
        color: gray;
      }
      a:focus{
        outline: none;
        box-shadow: none;
      }
      a {
        text-decoration: none;
        font-size: 18px;
        color: #6a6a6a;
      }
      svg {
        color: #676766;
      }
    }
  }

  .duplicate-modal, .delete-campaign-modal{
    text-align: center;
    justify-content: center;
    align-items: center;
    display: flex;
    #campaign_name{
      width:100%;
      height: 35px;
    }
  }

  .action .managing-button {
    border-radius: 2px;
    border: 2px solid #5b4181;
    color: #5b4181;
    background-color: white;
  }

  .action .managing-button:hover {
    background-color: rgba(128, 128, 128, 0.2);
  }

  .no-hover {
    pointer-events: none;
  }

  .border-theme {
    border: 2px solid #5b3e82;
  }

  .two-line-text {
   overflow: hidden;
   text-overflow: ellipsis;
   display: -webkit-box;
   -webkit-line-clamp: 2; /* number of lines to show */
   -webkit-box-orient: vertical;
   max-width: 390px;
  }

  .mw-col {
    width: 390px;
    @media screen and (max-width: 768px) and (min-width: 425px) {
      width: 100px;
    }
  }

  .delete-campaign-modal {
    padding: 0 56px;
  }

  .mobile-support > ul {
    list-style-type: none;
    padding-inline-start: 0px;

    .d-flex {
      display: flex;
    }

    .flex-column {
      flex-direction: column;
    }

    span.ml-5 {
      margin-right: 5px;
    }

    > li {
      padding: 5px 0px;
      height: 120px;
      border-bottom: 1px solid gray;

      .campaign-info {

        .campaign-name {
          height: 40%;
          padding-top: 5%;
          position: relative;

          .toggle-button {
            position: absolute;
            left: 220px;
            top: -10%;
          }

          // .toggle-button-active {
          //   position: absolute;
          //   left: 77%;
          //   top: -10%;
          // }
        }

        .campaign-detail {
          height: 60%;

          .column-info {
            margin: 3px;
            justify-content:space-between;
          }
        }
      }
    }
  }

</style>