<template>
<div>	
	<div class="mdc-layout-grid__inner scheduled-cards-container">
	  <div class="mdc-layout-grid__cell mdc-layout-grid__cell--span-12">
	    <table class="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
	      <thead>
	      <tr>
	        <th class="mdl-data-table__cell--non-numeric">Status</th>
	        <th class="mdl-data-table__cell--non-numeric">Name</th>
	        <th class="mdl-data-table__cell--non-numeric">Location</th>
	        <th class="mdl-data-table__cell--non-numeric"></th>
	      </tr>
	      </thead>
	      <tbody>
	        <tr v-if="postcards.length == 0">
	          <td colspan="4" style="text-align:center">Sent postcards will appear here.</td>
	        </tr>
          <tr v-else v-for="postcard in thisPostcards" id="`postcard-${postcard.id}`">
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
            <td>{{ postcard.city }}, {{ postcard.state }}, {{ postcard.country }}</td>
            <td>
              <i v-if="(postcard.sent || postcard.canceled) == false"
	              v-on:click="showModalConfirmCancelPostcard(postcard.id)"
              	class="material-icons mdc-button__icon cancel-postcard-button-icon"
              	v-b-tooltip.hover title="Cancel postcard">
              cancel
	            </i>
            </td>
          </tr>
	      	<tr>
	      		<td colspan="4">
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
	      <strong><h3>Are you sure you want to cancel this postcard? This can't be undone.</h3></strong>
	    </div>
	    <div>
	      <button v-on:click="closeModalConfirmCancelPostcard" class="mdc-button mdc-button--stroked"> Cancel </button>
	      <button v-on:click="cancelPostcard" class="mdc-button mdc-button--stroked"> OK </button>
	    </div>
	  </div>
	</modal>

</div>
</template>
<script>
	import axios from "axios"
	import CustomPagination from '../campaigns/pagination.vue'

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
			CustomPagination
		},

		data: function() {
			return {
				id: "",
				thisPostcards: this.postcards,
				thisTotalPages: this.totalPages,
				currentPage: parseInt(this.searchParams.page) || 1
			}
		},

		methods: {
			cancelPostcard: function () {
				let _this = this;
				let target = `/dashboard/${_this.id}/cancel_postcard.json`;
				axios.patch(target, { params: { id: _this.id } })
					.then(function(response) {
						let index = _this.thisPostcards.findIndex(function (postcard) {
							return postcard.id == _this.id;
						});
						_this.thisPostcards.splice(index, 1, JSON.parse(response.data.postcard));
						_this.closeModalConfirmCancelPostcard();
					}).catch(function (error) {
				})
			},

			showModalConfirmCancelPostcard: function (id) {
				this.id = id;
        this.$modal.show('cancel-postcard-modal');
			},

			closeModalConfirmCancelPostcard: function () {
				this.id = "";
        this.$modal.hide('cancel-postcard-modal');
			}
		}

	}
</script>
<style type="text/css" scoped>
	.cancel-postcard-button-icon {
		cursor: pointer;
	}
</style>