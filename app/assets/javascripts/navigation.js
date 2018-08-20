$(function() {
  $("#toggle_navigation").click(function() {
    return $("#single_column_navigation").toggle();
  });
  return $("#toggle_admin_navigation").click(function() {
    return $("#single_column_admin_navigation").toggle();
  });
});
