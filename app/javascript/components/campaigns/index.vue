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
          <input :placeholder="'SEARCH'" v-model="searchCampaignNameKeyword" @input="onSearchChange" class="border-theme"/>
        </div>
      </div>
      <div v-if="$screen.width > 425">
        <table class="campaign-dashboard">
          <tr>
            <th width="35px">
              <input id="campaign-check-all" type="checkbox" v-model="selectAll" style="margin:3px 4px" />
            </th>
            <th></th>
            <th width="120px">Design</th>
            <th class="mw-col">
              Name
              <span v-on:click="onSort('campaign_name')">
                <font-awesome-icon icon="caret-down" v-if="currentSortBy == 'campaign_name' && currentOrder == 'desc'" />
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
            <th v-for="column in tableColumns" :key="column[1]">
              {{ column[0] }}
              <span v-on:click="onSort(column[1])">
                <font-awesome-icon icon="caret-down" v-if="currentSortBy == column[1] && currentOrder == 'desc'" />
                <font-awesome-icon icon="caret-up" v-else/>
              </span>
            </th>
          </tr>
          <tr v-for="item in thisCampaigns" :key="item.id">
            <td class="checkbox-cell">
              <input type="checkbox" v-model="selected" :value="item.id" number/>
            </td>
            <td>
              <span v-if="['Out of credit', 'Error', 'Draft', 'Complete'].includes(item.campaign_status)">
                <md-switch class="md-primary" disabled />
              </span>
              <span v-else>
                <md-switch :value="!item.enabled" class="md-primary" @change="onChangeCampaignActive(item.id)" :disabled="disableToggle(item)" />
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
              <span v-on:click="onClickEditCampaign(item.id)" class="campaign-name-style two-line-text">{{ item.campaign_name | truncate(45) }}</span>
            </td>
            <td>{{ item.campaign_status}}</td>
            <td>{{ item.campaign_type }}</td>
            <td class="budget-max-width">
              <span class='t-b'> {{ item.campaign_type == "Automation" && item.budget != "-" ? `$${item.budget.toLocaleString('en-us')}/month` : item.budget }}</span>
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
          <li class="d-flex" v-for="item in thisCampaigns" :key="item.campaign_status">
            <span class="d-flex ml-5">
              <PreviewImage
                :key="item.id"
                :front-image="item.front_json.background_url"
                :back-image="item.back_json.background_url"
              />
            </span>
            <span class="campaign-info d-flex flex-column">
              <div class="campaign-name">
                <span v-on:click="onClickEditCampaign(item.id)" class="campaign-name-style two-line-text">{{ item.campaign_name | truncate(30) }}</span>
                <span v-if="['Out of credit', 'Error', 'Draft', 'Complete'].includes(item.campaign_status)" class="toggle-button">
                  <md-switch class="md-primary" disabled />
                </span>
                <span class="toggle-button" v-else>
                  <md-switch :value="!item.enabled" class="md-primary" @change="onChangeCampaignActive(item.id)" :disabled="disableToggle(item)" />
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
                  <span>{{ item.campaign_type == "Automation" && item.budget != "-" ? `$${item.budget.toLocaleString('en-us')}/month` : item.budget }}</span>
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
          :key="currentPage"
        > 
        </CustomePagination>
      </div>
    </div>
    <modal name="duplicateModal" :classes="'duplicate-modal'" :width="450" :height="200" :clickToClose="false">
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
    </modal>

    <modal name="deleteCampaignModal" classes="delete-campaign-modal" width="450" height="200" :clickToClose="false">
      <div>
        <div>
          <strong><h3>This action cannot be undone and any pending postcards in this campaign will be canceled. Are you sure you want to delete the campaign(s)?</h3></strong>
        </div>
        <div>
          <button v-on:click="closeModalConfirmDeleteCampaign" class="mdc-button mdc-button--stroked"> Cancel </button>
          <button v-on:click="deleteCampaigns" class="mdc-button mdc-button--stroked"> Delete </button>
        </div>
      </div>
    </modal>
    <LoadingDialog :modalDisplay="loading" />
    <b-alert :show="flashMessage != ''" variant="danger" class="top-alert">{{ flashMessage }}</b-alert>
  </div>
</template>

<script>
  /* global Turbolinks */
  import axios from 'axios';
  import DropdownMenu from './dropdown_menu.vue';
  import _ from 'lodash';
  import CustomePagination from './pagination.vue';
  import PreviewImage from './campaign_index_preview_image.vue';
  import { MAXIMUM_CAMPAIGN_NAME_LENGTH } from '../../config.js';
  import LoadingDialog from '../utilities/loading_dialog.vue';

  export default {
    components: {
      DropdownMenu,
      CustomePagination,
      PreviewImage,
      LoadingDialog,
    },
    props: {
      campaigns: {
        type: Array,
        required: true
      },
      searchParams: {
        type: Object
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
        currentPage: parseInt(this.searchParams.page) || 1,
        inputTimer: null,
        currentSortBy: this.searchParams.sort_by,
        currentOrder: this.searchParams.order || 'asc',
        duplicateCampaignName: "",
        loading: false,
        searchCampaignNameKeyword: this.searchParams.campaign_name || "",
        flashMessage: '',
        tableColumns: [
          ["Status", "campaign_status"],
          ["Type", "campaign_type"],
          ["Budget", "budget"],
          ["Starts", "send_date_start"],
          ["Ends", "send_date_end"]
        ],
      }
    },

    created() {
      console.log(this.thisCampaigns[0]);
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
    },

    methods: {
      showModalConfirmDuplicate() {
        const selectedCampaignName = this.thisCampaigns.find(campaign => campaign.id == this.selected).campaign_name
        this.duplicateCampaignName = "Copy of " + selectedCampaignName;
        if(this.duplicateCampaignName.length > MAXIMUM_CAMPAIGN_NAME_LENGTH) {
          this.duplicateCampaignName = selectedCampaignName;
        }
        this.$modal.show('duplicateModal')
      },

      closeModalConfirmDuplicateCampaign() {
        this.$modal.hide('duplicateModal')
      },

      showModalConfirmDeleteCampaign() {
        this.$modal.show('deleteCampaignModal')
      },

      closeModalConfirmDeleteCampaign() {
        this.$modal.hide('deleteCampaignModal')
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

      onChangeCampaignActive(campaign_id) {
        this.loading = true;
        let target = `/automations/${campaign_id}/toggle_pause`;
        axios.put(target).then(res => {
          let index = this.thisCampaigns.findIndex(campaign => campaign.id == campaign_id);
          let updateCampaign = JSON.parse(res.data.campaign);
          this.thisCampaigns[index] = updateCampaign;
          this.$forceUpdate();
          this.loading = false;
        }).catch(error => {});
      },

      onSearchChange() {
        clearTimeout(this.inputTimer);
        this.inputTimer = setTimeout(() => this.doSearchQuery(), 1000);
      },

      doSearchQuery() {
        let target = "/campaigns";
        let campaignNameKeyword = this.searchCampaignNameKeyword ? this.searchCampaignNameKeyword.toLocaleLowerCase() : "";
        if (campaignNameKeyword != "") {
          target += "?campaign_name=" + campaignNameKeyword;
        }
        Turbolinks.visit(target);
      },

      onSort(columnName) {
        let url = new URL(window.location.href);
        let order = this.currentSortBy == columnName && this.currentOrder == "asc" ? "desc" : "asc";
        url.searchParams.set("sort_by", columnName);
        url.searchParams.set("order", order);
        // Set current column sorted, and current order type
        this.currentSortBy = columnName;
        this.currentOrder = order;
        Turbolinks.visit(url.href);
      },

      deleteCampaigns() {
        let target = `/campaigns/delete_campaigns.json`;
        axios.delete(target, { params: {campaign_ids: this.selected } })
          .then((response) => {
            this.closeModalConfirmDeleteCampaign();
            this.reloadPage();
          }).catch();
      },

      duplicateCampaign() {
        if (this.selected.length == 1 && this.duplicateCampaignName) {
          axios.get('/campaigns/duplicate_campaign.json', { params: { campaign_id: this.selected[0], campaign_name: this.duplicateCampaignName } })
            .then((response) => {
              this.closeModalConfirmDuplicateCampaign();
              this.reloadPage();
            }).catch(() => this.showAlert("fill in campaign name!"));
        } else {
          this.showAlert("Please fill in campaign name!");
        }
      },

      collectParamsFilters() {
        // return this.$refs.DropdownMenu.collectParamsFilters()
        return null;
      },

      // User can't interact with toggle when campaign is in status sending and have type one-off
      disableToggle(campaign) {
        campaign.campaign_type == "One-off" && campaign.campaign_status == "Sending";
        return false;
      },

      splitedSchedule(schedule) {
        if (schedule == "Not set") {
          return ["Not set", "Not set"];
        } else if (schedule && schedule.includes(" &to& ")) {
          return [this.timeConverter(schedule.split(" &to& ")[0]), this.timeConverter(schedule.split(" &to& ")[1])];
        } else {
          return [this.timeConverter(schedule), ""]
        }
      },

      onClickNewCampaign() {
        Turbolinks.visit(`/automations/new`);
      },

      onClickEditCampaign(id) {
        Turbolinks.visit(`/automations/${id}/edit`);
      },

      reloadPage() {
        Turbolinks.visit(window.location.href);
      },

      showAlert(message) {
        this.flashMessage = message;
        clearTimeout(this.inputTimer);
        this.inputTimer = setTimeout(() => this.flashMessage = "", 3000);
      },

      timeConverter(time) {
        return time == "Not Set" || time == "Ongoing" ? time : this.moment(time, "YYYY-MM-DD HH:mm Z").format("ll");
      },
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

    .checkbox-cell input {
      margin: 3px 3px 3px 4px;
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

  #pagination .pagination-ul {
    text-align: center;
    list-style: none;
    padding-top: 13px;
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

    h3 {
      font-size: 1.17em;
      margin-block-start: 1em;
      margin-block-end: 1em;
      margin-inline-start: 0px;
      margin-inline-end: 0px;
      font-weight: bold;
    }

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

  .top-alert {
    position: fixed !important;
    top: 0;
    left: 0;
    width: 100%;
    height: 50px;
    z-index: 99999;
  }

  .budget-max-width {
    max-width: 100px;
  }
</style>
