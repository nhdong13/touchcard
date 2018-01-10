import Vue from 'vue/dist/vue.esm'
import CardSide from '../components/card_side.vue'

// console.log("Lob Render Pack: LOADING");

document.addEventListener('DOMContentLoaded', () => {

  var element = document.getElementById('lob-api-card-side');
  // debugger;
  if (element != null) {

    const vueApp = new Vue({
      el: element,
      template: `
        <card-side
            :attributes="attributes"
            :discount_pct="discount_pct"
            :discount_exp="discount_exp"
        >
        </card-side>`,
      data: function() {
        console.log('element:');
        console.log(element);
        return {
          attributes: {image: '', discount_x: 50, discount_y: 50}, // JSON.parse(element.dataset.attributes),
          discount_pct: 22, // JSON.parse(element.dataset.discount_pct),
          discount_exp: 3, // JSON.parse(element.dataset.discount_exp),
          discount_code: 'xoxoya' //JSON.parse(element.dataset.discount_code)
        }
      },
      components:{
        'card-side': CardSide
      },
    });
    window.Vue = vueApp;
  }
});


