$(function() {
  $('#sort_favorites').sortable({
    items: '> li',
    containment: 'parent',
    axis: 'y',
    cursor: 'move',
    update: function() {
      return $.post('/favorites/sort_favorites', $(this).sortable('serialize'), {
        complete: function(request) {
          return $('#sort_favorites').effect('highlight');
        }
      });
    }
  });
  return $('#sort_things').sortable({
    items: '> li',
    containment: 'parent',
    axis: 'y',
    cursor: 'move',
    update: function() {
      return $.post('/favorites/sort_things', $(this).sortable('serialize'), {
        complete: function(request) {
          return $('#sort_things').effect('highlight');
        }
      });
    }
  });
});
