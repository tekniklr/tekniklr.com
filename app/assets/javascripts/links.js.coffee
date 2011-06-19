$(document).ready ->
  $('#new_link').submit ->
    $.post $(@).attr('action'), $(@).serialize(), null, "script"
    false

$(document).ready ->
  $('a.delete').click ->
    if confirm $(@).attr('data-confirm')
      row = $(@).closest("div").get(0);
      $.post @href, { _method: 'delete' }, null, "script"
      $(row).hide()
      false
    else
      false