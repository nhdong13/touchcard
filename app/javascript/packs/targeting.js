$(document).ready(function() {
  let optionSections = [["#add-more-btn", ".option-list"], ["#second-add-more-btn", ".second-option-list"]];
  optionSections.forEach((item, index) => {
    let tmp = index == 0 ? acceptedOptions : removedOptions;
    $(item[0]).click(function() {
      if ($(item[1] + " .filter-container").length < 3) {
        $(item[1]).append(tmp);
        checkANDTitle();
      } else {
        alert("You can't add more than 3 conditions")
      }
    })
  })

  $(document).on("click", ".remove-filter", function() {
    $(this).parents(".filter-container").remove();
    checkANDTitle();
  });

  function checkANDTitle() {
    $(".second-option-list .filter-container").first().children("p.text-center").remove();
    $(".option-list .filter-container").first().children("p.text-center").remove();
  }
})
