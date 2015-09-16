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

function customBackground(){
  $("#bg_box_back").fadeToggle(500, "swing");
  if(document.getElementById("custom_background_back").innerHTML == "Go Custom - Add Background") {
    document.getElementById("custom_background_back").innerHTML = "No Custom Background"
  } else {
    document.getElementById("custom_background_back").innerHTML = "Go Custom - Add Background"
  }
}

$(function() {
  $(".coupon_box").draggable({ containment: "#front_display" });
  $(".coupon_box").css({'top': -100, 'left' : 20});
});
