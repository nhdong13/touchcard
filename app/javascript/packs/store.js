import Vue from 'vue'
// This store pattern only handle in small scale.
// If sometime in the future, the app scale, This pattern should be replaced by Vuex
// This is used to fake the result from server without making user wait for actual result
export default Vue.observable({
  campaign: {}
})