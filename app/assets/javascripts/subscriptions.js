/* global mdc */

document.addEventListener('turbolinks:load', function() {

  var quantitySlider = document.querySelector('.mdc-slider');
  var quantityDisplay = document.querySelector('.checkout-quantity-display');
  var quantitySelect = document.querySelector('.checkout-quantity-select');

  var checkoutPriceDisplay = document.querySelector('.checkout-display-price');



  // Note: This way only supports 1 slider per page.
  if (quantitySlider != null) {
    const slider = new mdc.slider.MDCSlider(document.querySelector('.mdc-slider'));
    slider.listen('MDCSlider:input', function() {
      quantitySelect.selectedIndex = slider.value;
      var selectedQuantity = quantitySelect.options[quantitySelect.selectedIndex].text;
      quantityDisplay.innerHTML = selectedQuantity;
      checkoutPriceDisplay.innerHTML = '$' + (selectedQuantity * 0.99).toFixed(2);
      // Value:  quantitySelect.options[quantitySelect.selectedIndex].value;


    });

  }


});


