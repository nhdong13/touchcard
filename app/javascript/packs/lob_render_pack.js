import Vue from 'vue/dist/vue.esm'
import CardSide from '../components/card_side'

console.log("Lob Render Pack: LOADING");

if (document.readyState == 'loading') {
  document.addEventListener('DOMContentLoaded', loadCardSide);
} else {
  loadCardSide();
}

function loadCardSide(){

  var element = document.getElementById('lob-api-card-side');
  debugger;
  if (element != null) {
    console.log("Lob Renderer Pack LOADING");
    const vueApp = new Vue({
      el: element,
      template: `
        <card-side
            :attributes="attributes"
            :discount_pct="discount_pct"
            :discount_exp="discount_exp"
            :enableDiscount="discount_exp && discount_pct"
        >
        </card-side>`,
      data: function() {
        console.log('element:');
        console.log(element);
        return {
          attributes: {image: 'https://touchcard-data-dev.s3.amazonaws.com/uploads/d687ec10-91e7-4bbc-828c-500887765189/__card_01.jpg', discount_x: 50, discount_y: 50}, // JSON.parse(element.dataset.attributes),
          discount_pct: 1, // JSON.parse(element.dataset.discount_pct),
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
}



