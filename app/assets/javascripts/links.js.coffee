$(document).ready ->
  $('#new_link').submit ->
    $.post $(@).attr('action'), $(@).serialize(), null, "script"
    false