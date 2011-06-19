# delete in an ajaxy way
$(document).ready ->
  $('a.delete').click ->
    if confirm $(@).attr('data-confirm')
      row = $(@).closest("div").get(0);
      $.post @href, { _method: 'delete' }, null, "script"
      $(row).hide()
      false
    else
      false
      
# show a message in the given div, #notification if not specified
# class defaults to 'notice', can also be 'error'
window.notify = (message, cssclass = 'notice', div = '#notification') ->
    $(div).html('') # if we don't do this the message 'flashes' before appearing
    $(div).hide(300)
    $(div).html('<div class="flash '+cssclass+'">'+message+'</div>')
    $(div).show(300)
    false