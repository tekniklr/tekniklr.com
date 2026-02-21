//= require Sortable
//= require jquery-sortable

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

$('#favorites').sortable({
  draggable: '.sort_favorite',
  handle: '.drag',
  direction: 'vertical',
  animation: 150,
  dataIdAttr: 'data-id',
  onUpdate: function(event) {
    var sorted_favorite_ids = $('#favorites').sortable('toArray');
    $.post('/favorites/sort_favorites', { favorite_ids: sorted_favorite_ids });
  }
});

$('.sort_favorite_things').sortable({
  draggable: '.sort_thing',
  containment: "parent",
  handle: '.nested_drag',
  direction: 'vertical',
  animation: 150,
  dataIdAttr: 'data-id',
  onUpdate: function(event) {
    var favorite_id = event.target.id;
    var sorted_thing_ids = $('#'+favorite_id).sortable('toArray');
    $.post('/favorites/sort_things', { thing_ids: sorted_thing_ids });
  }
});