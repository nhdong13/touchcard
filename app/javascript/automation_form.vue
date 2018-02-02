<template>
  <div>
    <button v-on:click="requestSave" class="mdc-button mdc-button--raised">Save</button>

    <!-- div v-cloak></div -->
    <h3>{{automation.type}}</h3>
    <card-editor
        ref="cardEditor"
        :discount_pct.sync="automation.discount_pct"
        :discount_exp.sync="automation.discount_exp"
        :front_attributes.sync="automation.front_json"
        :back_attributes.sync="automation.back_json"
        :aws_sign_endpoint="awsSignEndpoint"
    ></card-editor>
  </div>
</template>

<script>
  /* global Turbolinks */
  import axios from 'axios'
  import CardEditor from './components/card_editor.vue'

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
    beforeMount: function() {
      if (!this.isValidAttributes(this.automation.front_json)) {
        this.automation.front_json = this.defaultAttributes();
      }

      if (!this.isValidAttributes(this.automation.back_json)) {
        this.automation.back_json = this.defaultAttributes();
      }
    },
    // data: function() {
    //   return {
    //   };
    // },
    components: {
      // 'card-editor': () => ({
      //   // https://vuejs.org/v2/guide/components.html#Async-Components
      //   component: import('./components/card_editor.vue')
      //   // loading: LoadingComp, error: ErrorComp, delay: 200, timeout: 3000
      // })
      'card-editor': CardEditor
    },
    methods: {
      defaultAttributes: function() {
        return {
          'version': 0,
          'background_url': null,
          'discount_x': null, // default?
          'discount_y': null,
          // 'objects' : []
        };
      },
      isValidAttributes: function (attrs) {
        if (attrs === null) {
          return false;
        }
        let valid = true;
        let data = this.defaultAttributes();
        valid &= 'version' in attrs && attrs.version === data.version;
        for (var key in data) {
          // check if the property/key is defined in the object itself, not in parent
          if (data.hasOwnProperty(key)) {
            valid &= key in attrs;
          }
        }
        return valid;
      },
      requestSave: function() {

        // TODO: Wait for uploads to complete in CardEditor

        this.postOrPutForm();

        // // Ask the CardEditor to finish its uploads and serialization (attributes are writt
        // back via :props.sync)
        // this.$refs.cardEditor.requestSave()
        //   .then((results) => {
        //     console.log(results)
        //     this.postOrPutForm()
        //   }).catch(function (err) {
        //   console.log(err)
        // })
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
