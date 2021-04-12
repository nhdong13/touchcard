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

  $(document).on("change","#accepted_filter_", function() {
    toggleDatePicker(this)
  })

  $(document).on("change","#accepted_condition_", function() {
    toggleDatePicker($(this).prev())
  })

  function toggleDatePicker(e) {
    if ($(e).val() == 2 && ["3", "4", "5"].indexOf($(this).next().val()) >= 0) {
      $(e).parent().children("#accepted_value_[type='datetime-local']").css('display', '');
    } else {
      $(e).parent().children("#accepted_value_[type='datetime-local']").hide();
    }
  }

  $(".next-btn").click(function() {
    $(".filter").each(function() {
      if ($(this).val() == 2 && ["3", "4", "5"].indexOf($(this).next().val()) >= 0) {
        $(this).parent().children("#accepted_value_[type='number']").remove();
      } else {
        $(this).parent().children("#accepted_value_[type='datetime-local']").remove();
      }
    })
  })
})
