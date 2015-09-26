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
  var current_loc = $("#coupon_loc").val();
  console.log(current_loc);
  if(typeof current_loc  === 'undefined'){
  } else {
    var current_left = current_loc.split(",")[0] + "%";
    var current_top = current_loc.split(",")[1] + "%";
    $(".coupon_box").css({'top': current_top, 'left' : current_left});
  }

  $(".coupon_box").draggable({
    containment: "#front_display",
    drag: function(){
      var offset = $(this).offset();
      var xPos = offset.left;
      var yPos = offset.top;
    },
    stop: function(){
      var frontDisplay = $("#front_display").offset();
      var width = $(".card_display").width();
      var height = $(".card_display").height();
      var finalOffset = $(this).offset();
      var finalxPos = finalOffset.left - frontDisplay.left;
      var finalyPos = finalOffset.top - frontDisplay.top;
      var xPct = (finalxPos/width)*100
      var yPct = (finalyPos/height)*100

      new_loc = xPct.toFixed(2) + "," + yPct.toFixed(2);
      console.log(new_loc);
      $("#coupon_loc").val(new_loc);

    },
  });
})

// Show/hide the coupon fields
function flipCoupon(){
  $(".coupon_display").toggle();
  $(".coupon_form").toggle();
}
