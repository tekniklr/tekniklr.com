//= require Sortable
//= require jquery-sortable

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

$('.goty_edit').sortable({
  draggable: 'li',
  direction: 'vertical',
  handle: '.drag',
  animation: 150,
  ghostClass: 'item_dragging',
  dataIdAttr: 'data-id',
  onUpdate: function(evt) {
    var sorted_ids = $('.goty_edit').sortable('toArray');
    $.post('/goty/sort', { game_ids: sorted_ids });
  }
});