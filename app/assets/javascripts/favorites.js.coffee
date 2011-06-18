$('#sort_things').sortable
  items: '.favorite_thing',
  containment:'parent',
  axis:'y',
  update: ->
    $.post '/favorites/sort',
    '_method=put&' + $('#sort_things').sortable('serialize'),
    complete: (request) ->
      $('#sort_things').effect 'highlight'