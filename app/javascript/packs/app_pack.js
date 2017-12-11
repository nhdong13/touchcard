import axios from 'axios'
import loadAutomationEditor from '../automation_form'

// To get Turbolinks working it helped to put the javascript pack tag in the <head>
// If we need to expand Vue to other parts of the application I suspect it would help
// to keep this structure and load individual containers loaded from this file.
// (with Webpacker code splitting if necessary)

document.addEventListener('turbolinks:load', () => {

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('automation-editor');

  if (element != null) {
    const vueApp = loadAutomationEditor(element);
    window.Vue = vueApp;
  }
});