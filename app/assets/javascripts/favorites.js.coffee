$ ->
  $('#sort_favorites').sortable
    items: '> li',
    containment:'parent',
    axis:'y',
    cursor: 'move',
    update: ->
      $.post '/favorites/sort_favorites',
      $(@).sortable('serialize'),
      complete: (request) ->
        $('#sort_favorites').effect 'highlight'

  $('#sort_things').sortable
    items: '> li',
    containment:'parent',
    axis:'y',
    cursor: 'move',
    update: ->
      $.post '/favorites/sort_things',
      $(@).sortable('serialize'),
      complete: (request) ->
        $('#sort_things').effect 'highlight'
