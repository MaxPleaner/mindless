(function() {
  $(function() {
    return $(".grid").masonry({
      itemSelector: '.grid-item',
      columnWidth: 200
    });
  });

}).call(this);
