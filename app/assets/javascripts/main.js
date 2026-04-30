$(document).ready(function() {
  $('.spoiler button').on('click', function() {
    var spoiler_div = $(this).parent().parent();
    var content_div = spoiler_div.siblings('.content');
    spoiler_div.hide();
    content_div.fadeIn('normal');
  });
});