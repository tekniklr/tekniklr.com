$(document).ready ->
  $('#new_exp').submit ->
    $.post $(@).attr('action'), $(@).serialize(), null, "script"
    false