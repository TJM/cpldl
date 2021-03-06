$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#course_title", function() {
    if($("#course_seo_page_title").val().trim() === "") {
      $("#course_seo_page_title").val($("#course_title").val());
    }
  });

  // If the user enters text in the topics textbox, mark the checkbox too.
  $("body").on("change", "#course_other_topic_text", function() {
    if($(this).val().trim() !== "") {
      $("#course_other_topic").prop("checked", true);
    }
  });

  $("#course_title").simplyCountable({
    counter: "#course_title_counter",
    countable: "characters",
    maxCount: 40,
    strictMax: true,
    countDirection: "down"
  });

  $("#course_seo_page_title").simplyCountable({
    counter: "#course_seo_page_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
  });

  $("#course_summary").simplyCountable({
    counter: "#course_summary_counter",
    countable: "characters",
    maxCount: 74,
    strictMax: true,
    countDirection: "down"
  });

  $("#course_meta_desc").simplyCountable({
    counter: "#course_meta_desc_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
  });

///////////////////////////// moved to view ////////////////////////////////////
///////////////// due to asset pipeline bug in production //////////////////////

  $(".course_pub").on("change", function(){ //listen for a change on the given selector(id)
    var courseId = $(this).data("courseId");
    var value = $(this).val();
    if(value == "A"){
      var r = confirm("Are you sure you want to Archive this item? Archiving means it will no longer be avaliable to edit or view.");
    } else {
      var r = true
    }

    if(r == true){
      $.ajax({
        url: "/admin/courses/" + courseId + "/update_pub_status/",
        data: { "value": value },
        dataType: "json",
        type: "PATCH"
      });
    } else {
      location.reload(true);
    }
  });

  $("#course_pub_status").on("change", function(){
    var value = $(this).val();
    var currentStatus = $(this).data("status")

    if(value == "A"){
      var rconfirm = confirm("Are you sure you want to Archive this item? Archiving means it will no longer be avaliable to edit or view.");
    }

    if(rconfirm == false){
      $("#course_pub_status").val(currentStatus);
    } else {
      confirm.stopPropagation();
      $("#course_pub_status").val(value);
    }
  });

////////////////////////////////////////////////////////////////////////////////
});

  // remove attachment fields in Course form
  $(function () {
    $(document).delegate('.remove_child','click', function() {
      $(this).parent().children('.removable')[0].value = 1;
      $(this).prev().slideUp();
      $(this).slideUp();

      return false;
    });
   });

  // add attachment fields in Course form
  function add_fields(association, content, prefix) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g")
    $("#add-attachment-" + prefix).before(content.replace(regexp, new_id));

  };
