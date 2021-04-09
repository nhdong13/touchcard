<template>
  <div>
    <div :class="'action'">
      <button> Duplicate </button>
      <button> Edit </button>
      <button v-on:click="deleteCampaigns"> Delete </button>
      <button> CSV </button>
      <button> Filter </button>
      <input :placeholder="'Search'" v-model="searchQuery"/>
    </div>
    <div>
      <table>
        <tr>
          <th>
            <input id="campaign-check-all" type="checkbox" v-model="selectAll"/>
          </th>
          <th>Name</th>
          <th>Type</th>
          <th>Status</th>
          <th>Budget</th>
          <th>Schedule</th>
        </tr>
        <tr v-for="item in resultQuery">
          <td>
            <input id="campaign-check-all" type="checkbox" v-model="selected" :value="item.id" number/>
          </td>
          <td>{{ item.type }}</td>
          <td>{{ item.type }}</td>
          <td>{{ campaignStatus(item.enabled) }}</td>
          <td>{{ name }}</td>
          <td>{{ name }}</td>
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
  import axios from 'axios'

  export default {
    props: {
      campaigns: {
        type: Array,
        required: true
      },
      totalPages: {
        type: Number,
        required: true
      }
    },

    data: function() {
       return {
        thisCampaigns: this.campaigns,
        name: "Post sale card",
        selected: [],
        thisTotalPages: this.totalPages,
        currentPage: 1,
        searchQuery: null,
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

      resultQuery(){
        if(this.searchQuery){
          return this.thisCampaigns.filter((item)=>{
            return this.searchQuery.toLowerCase().split(' ').every(v => item.type.toLowerCase().includes(v))
          })
        }else{
          return this.thisCampaigns;
        }
      }
    },

    beforeCreate() {
      console.log("before create")
      console.log(this.message)
    },

    watch: {
    },

    components: {
    },

    methods: {
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
        axios.get(target, { params: {page: pageNum} })
          .then(function(response) {
            _this.thisCampaigns = response.data
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
              _this.thisCampaigns = JSON.parse(response.data.campaigns)
              _this.thisTotalPages = response.data.total_pages
              _this.selected = []
              _this.currentPage = 1
            }).catch(function (error) {
          });
        }
      }
    }
  }

</script>
<style lang="scss">
  table {
    width: 100%;
  }

  table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
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