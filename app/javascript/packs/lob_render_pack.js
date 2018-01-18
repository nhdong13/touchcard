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
        return {
          attributes: JSON.parse(element.dataset.attributes),
          discount_pct: Number(element.dataset.discountPct),
          discount_exp: Number(element.dataset.discountExp),
          discount_code: element.dataset.discountCode
        }
      },
      mounted: function () {
        // Set a div that signals completion to Selenium
        let signalingDiv = document.createElement('div');
        signalingDiv.setAttribute('class', 'render-complete');
        document.head.appendChild(signalingDiv);
      },
      components:{
        'card-side': CardSide
      },
    });
    window.Vue = vueApp;
  }
}



