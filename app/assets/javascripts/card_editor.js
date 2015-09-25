// Remove the custom background image on the front
function removeCustomFront(){

}

// Remove the custom background image on the back
function removeCustomBack(){

}

// Remove the custom logo
function removeLogo(){

}

// function to show/hide front text boxes
function removeFrontText(){
  document.getElementById("master_card_title_front").value = "";
  document.getElementById("master_card_text_front").value = "";
  $(".card_editor_fields").fadeToggle(500, "swing");
  if(document.getElementById("no_text").innerHTML == "Go Custom - Add a Custom Message") {
    document.getElementById("no_text").innerHTML = "Go Custom - Remove Editable Text"
  } else {
    document.getElementById("no_text").innerHTML = "Go Custom - Add a Custom Message"
  }
}

// Function to show the custom background image box for the back side
function customBackground(){
  $("#bg_box_back").fadeToggle(500, "swing");
  if(document.getElementById("custom_background_back").innerHTML == "Go Custom - Add Background") {
    document.getElementById("custom_background_back").innerHTML = "No Custom Background"
  } else {
    document.getElementById("custom_background_back").innerHTML = "Go Custom - Add Background"
  }
}

// Make the coupon box draggable
$(function() {
  $(".coupon_box").draggable({ containment: "#front_display" });
});

// Show/hide the coupon fields
function flipCoupon(){
  $(".coupon_display").toggle();
  $(".coupon_form").toggle();
}
