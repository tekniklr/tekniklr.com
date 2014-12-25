$('#sort_favorites').sortable
  items: '.favorite',
  containment:'parent',
  axis:'y',
  update: ->
    $.post '/favorites/sort_favorites',
    '_method=patch&' + $(@).sortable('serialize'),
    complete: (request) ->
      $('#sort_favorites').effect 'highlight'

$('#sort_things').sortable
  items: '.favorite_thing',
  containment:'parent',
  axis:'y',
  update: ->
    $.post '/favorites/sort_things',
    '_method=patch&' + $(@).sortable('serialize'),
    complete: (request) ->
      $('#sort_things').effect 'highlight'
