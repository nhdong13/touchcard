<template>
  <div>
    <button v-on:click="requestSave">Save</button>
    <!-- div v-cloak></div -->
    <h3>{{automation.type}}</h3>
    <card-editor
        ref="cardEditor"
        :discount_pct.sync="automation.discount_pct"
        :discount_exp.sync="automation.discount_exp"
        :front_attributes.sync="automation.card_side_front_attributes"
        :back_attributes.sync="automation.card_side_back_attributes"
        :aws_sign_endpoint="awsSignEndpoint"
    ></card-editor>

    <hr />
  </div>
</template>

<script>
  /* global Turbolinks */
  import axios from 'axios'

  export default {
    props: {
      id: {
        required: false
      },
      automation: {
        type: Object,
        required: true
      },
      awsSignEndpoint: {
        type: String,
        required: true
      }
    },
    // data: function() {
    //   return {
    //   };
    // },
    components: {
      'card-editor': () => ({
        // https://vuejs.org/v2/guide/components.html#Async-Components
        component: import('./components/card_editor.vue')
        // loading: LoadingComp, error: ErrorComp, delay: 200, timeout: 3000
      })
    },
    methods: {
      requestSave: function() {
        // Ask the CardEditor to finish its uploads and serialization (attributes are written back via :props.sync)
        this.$refs.cardEditor.requestSave()
          .then((results) => {
            console.log(results)
            this.postOrPutForm()
          }).catch(function (err) {
          console.log(err)
        })
      },
      postOrPutForm: function() {
        if (this.id) {
          // Edit existing automation (PUT)
          let target = `/automations/${this.id}.json`;
          axios.put(target, { card_order: this.automation })
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
            console.log(error);
          });
        } else {
          // Create a new automation (POST)
          axios.post('/automations.json', { card_order: this.automation})
            .then(function(response) {
              console.log(response);
              Turbolinks.visit('/automations');
            }).catch(function (error) {
            console.log(error);
          });
        }
      }
    }
  }
</script>

<style scoped>
  [v-cloak] {
    display: none;
  }
</style>
