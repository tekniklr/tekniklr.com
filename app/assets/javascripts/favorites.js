$('#sort_favorites').sortable({
  draggable: 'li',
  handle: '.drag',
  direction: 'vertical',
  animation: 150,
  ghostClass: 'item_dragging',
  dataIdAttr: 'data-id',
  onUpdate: function(evt) {
    var sorted_ids = $('#sort_favorites').sortable('toArray');
    return $.post('/favorites/sort_favorites', { favorite_ids: sorted_ids }, {
      complete: function(request) {
        return $('#sort_favorites').effect('highlight');
      }
    });
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
    return $.post('/favorites/sort_things', { thing_ids: sorted_ids }, {
      complete: function(request) {
        return $('#sort_things').effect('highlight');
      }
    });
  }
});