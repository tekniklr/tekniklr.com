//= require Sortable
//= require jquery-sortable

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

$('#sort_favorites').sortable({
  draggable: 'li',
  handle: '.drag',
  direction: 'vertical',
  animation: 150,
  ghostClass: 'item_dragging',
  dataIdAttr: 'data-id',
  onUpdate: function(evt) {
    var sorted_ids = $('#sort_favorites').sortable('toArray');
    $.post('/favorites/sort_favorites', { favorite_ids: sorted_ids });
  }
});

$('#sort_things').sortable({
  draggable: 'li',
  handle: '.drag',
  direction: 'vertical',
  animation: 150,
  ghostClass: 'item_dragging',
  dataIdAttr: 'data-id',
  onUpdate: function(evt) {
    var sorted_ids = $('#sort_things').sortable('toArray');
    $.post('/favorites/sort_things', { thing_ids: sorted_ids });
  }
});