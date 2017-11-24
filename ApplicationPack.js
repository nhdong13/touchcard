import axios from 'axios'

import loadAutomationEditor from '../containers/AutomationEditor'


console.log("\n\n=== AutomationEditorPack.js ===\n\n");

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('automation-editor');

  if (element != null) {
    const vueApp = loadAutomationEditor(element);
    window.tc = vueApp;
  }
});