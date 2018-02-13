
export default function options(element) {
  return {
    el: element,
    props: {
      // suggestedQuantity: {
      //   required: false
      // }
    },
    data: function() {
      return {
        slider: null
      }
    },
    mounted: function() {
      this.slider  = new mdc.slider.MDCSlider(this.$refs.quantitySlider);
      this.updateQuantity();
      this.slider.listen('MDCSlider:input', () => {
        this.updateQuantity();
      });
    },
    methods: {
      updateQuantity: function() {
        console.log(this.slider.value);

        let index = this.slider.value;
        this.$refs.quantitySelect.selectedIndex = index;
        let selectedQuantityText = this.$refs.quantitySelect.options[index].text;
        this.$refs.quantityDisplay.innerHTML = selectedQuantityText;

        let price = (selectedQuantityText * 0.99).toFixed(2);
        this.$refs.checkoutPriceDisplay.innerHTML = '$' + price;
        window.checkoutPriceDisplay = price;
      },
    }
  }
}
