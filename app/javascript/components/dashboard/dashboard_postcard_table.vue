<template>
<div>	
  <div class="mdc-layout-grid__inner scheduled-cards-container">
    <div class="mdc-layout-grid__cell mdc-layout-grid__cell--span-12">
      <table class="mdl-data-table mdl-js-data-table mdl-shadow--2dp table-max-width">
        <thead>
        <tr>
          <!-- <th class="mdl-data-table__cell--non-numeric status-column">Status</th>
          <th class="mdl-data-table__cell--non-numeric name-column">Name</th>
          <th class="mdl-data-table__cell--non-numeric campaign-column">Campaign</th>
          <th class="mdl-data-table__cell--non-numeric location-column">Location</th> -->
          <th class="mdl-data-table__cell--non-numeric" v-for="column in tableColumns" :key="column[1]" :class="`${column[1]}-column`">
            {{ column[0] }}
            <span v-on:click="onSort(column[1])" class="pointer">
              <font-awesome-icon icon="caret-down" v-if="currentSortBy == column[1] && currentOrder == 'desc'" />
              <font-awesome-icon icon="caret-up" v-else/>
            </span>
          </th>
          <th class="mdl-data-table__cell--non-numeric cancel-btn-column"></th>
        </tr>
        </thead>
        <tbody>
          <tr v-if="postcards.length == 0">
            <td colspan="4" style="text-align:center">Sent postcards will appear here.</td>
          </tr>
          <tr v-else v-for="postcard in thisPostcards" :id="`postcard-${postcard.id}`" :key="postcard.id">
            <td>
              <button type="button"
                      class="mdl-chip postcard-status-chip"
                      :class="[postcard.sent ? 'mdl-color--light_green' : 'mdl-color--orange']">
                <span class="mdl-chip__text" v-if="postcard.canceled">Canceled</span>
                <span class="mdl-chip__text" v-else-if="postcard.sent">Sent on {{ postcard.date_sent }}</span>
                <span class="mdl-chip__text" v-else>Sending {{ postcard.send_date }}</span>
              </button>
            </td>

            <td>{{ postcard.full_name }}</td>
            <td :class="{ 'gray-text': postcard.campaign_deleted }">{{ postcard.campaign_name | truncate(35) }}</td>
            <td>{{ postcard.city }}, {{ postcard.state }}, {{ postcard.country }}</td>
            <td class="cancel-btn">
              <i v-if="(postcard.sent || postcard.canceled) == false"
                v-on:click="showModalConfirmCancelPostcard(postcard.id)"
                class="material-icons mdc-button__icon cancel-postcard-button-icon"
                v-b-tooltip title="Cancel postcard">
              cancel
              </i>
            </td>
          </tr>
          <tr>
            <td colspan="5">
              <div id="pagination">
                <CustomPagination
                  v-model="currentPage"
                  :total-page="thisTotalPages"
                  :key="currentPage"
                > 
                </CustomPagination>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <modal name="cancel-postcard-modal" classes="delete-campaign-modal" width="450" height="200" :clickToClose="false">
    <div>
      <div>
        <strong><h3>This action cannot be undone. Are you sure you want to cancel this postcard?</h3></strong>
      </div>
      <div>
        <button v-on:click="closeModalConfirmCancelPostcard" class="mdc-button mdc-button--stroked"> Back </button>
        <button v-on:click="cancelPostcard" class="mdc-button mdc-button--stroked"> OK </button>
      </div>
    </div>
  </modal>

  <modal name="cannot-cancel-postcard-modal" classes="delete-campaign-modal" width="450" height="200" :clickToClose="false">
    <div>
      <div>
        <strong v-if="isPostcardSent"><h3>Unable to cancel because this postcard has already been sent.</h3></strong>   
        <strong v-else><h3>Unable to cancel because this postcard has already been canceled.</h3></strong>
      </div>
      <div>
        <button v-on:click="closeModalCannotCancelPostcard" class="mdc-button mdc-button--stroked"> OK </button>
      </div>
    </div>
  </modal>
  <LoadingDialog :modalDisplay="loading" />
</div>
</template>
<script>
  import axios from "axios"
  import CustomPagination from '../campaigns/pagination.vue'
  import LoadingDialog from '../utilities/loading_dialog.vue'
  export default {
    props: {
      postcards: {
        type: Array,
        required: true
      },
      totalPages: {
        type: Number,
        required: true
      },
      searchParams: {
        type: Object
      }
    },
    
    components: {
      CustomPagination,
      LoadingDialog
    },

    data: function() {
      return {
        id: "",
        thisPostcards: this.postcards,
        thisTotalPages: this.totalPages,
        currentPage: parseInt(this.searchParams.page) || 1,
        loading: false,
        isPostcardSent: false,
        currentSortBy: this.searchParams.sort_by,
        currentOrder: this.searchParams.order,
        campaignId: this.searchParams.campaign_id,
        tableColumns: [
          ['Status', 'status'],
          ['Name', 'name'],
          ['Campaign', 'campaign'],
          ['Location', 'location']
        ]
      }
    },

    methods: {
      cancelPostcard: function () {
        this.$modal.hide("cancel-postcard-modal");
        this.loading = true;
        let _this = this;
        let target = `/dashboard/${this.id}/cancel_postcard.json`;
        axios.patch(target, { params: { id: this.id } })
          .then((response) => {
            if (response.data.message === 'canceled') {
              return this.reloadPostcards();
            }

            if (response.data.message === 'cannot cancel') {
              _this.isPostcardSent = response.data.postcard_sent;
              _this.loading = false;
              _this.$modal.show('cannot-cancel-postcard-modal');
            }
          }).catch(function (error) {
        })
      },

      reloadPostcards: function () {
        this.loading = true;
        this.id = "";
        let _this = this;
        let indexParams = {
          page: this.currentPage,
          sort_by: this.currentSortBy,
          order: this.currentOrder,
          campaign_id: this.campaignId
        };
        axios.get('/dashboard.json', { params: indexParams })
          .then(function(response) {
            _this.thisPostcards = JSON.parse(response.data.postcards);
            _this.loading = false;
          }).catch(function(error) {
          })
      },

      showModalConfirmCancelPostcard: function (id) {
        this.id = id;
        this.$modal.show('cancel-postcard-modal');
      },

      closeModalConfirmCancelPostcard: function () {
        this.reloadPostcards();
        this.$modal.hide('cancel-postcard-modal');
      },

      closeModalCannotCancelPostcard: function () {
        this.reloadPostcards();
        this.$modal.hide('cannot-cancel-postcard-modal');
      },

      onSort: function(columnName) {
        let url = new URL(window.location.href);
        let order = this.currentSortBy == columnName && this.currentOrder == 'asc' ? 'desc' : 'asc';
        url.searchParams.set('sort_by', columnName);
        url.searchParams.set('order', order);
        this.currentSortBy = columnName;
        this.currentOrder = order;
        Turbolinks.visit(url.href);
      }
    },

    filters: {
      truncate: function(data, num) {
        if (data.length <= num) return data;
        let truncateName = data.substring(0, num) + "..."
        return truncateName;
      }
    }
  }
</script>
<style type="text/css" scoped>
  .cancel-postcard-button-icon {
    cursor: pointer;
  }

  .cancel-btn {
    text-align: center;
    padding-left: 6px;
  }
  
  .table-max-width {
    table-layout: fixed;
    width: 1075px;
  }

  .status-column {
    width: 160px;
  }
  
  .name-column {
    width: 200px;
  }

  .campaign-column {
    width: 250px;
  }

  .location-column {
    width: 300px;
  }
  
  .cancel-btn-column {
    width: 40px;
    padding-left: 6px;
  }

  .gray-text {
    color: gray;
  }
  
  .pointer {
    cursor: pointer;
  }
</style>