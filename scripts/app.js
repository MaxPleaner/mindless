(function() {
  var getContent, getGrid, getGridItems, gridItemOnClick, makeHidden, masonryOptions, resizeBoxToVisibleContent, setupMasonry;

  masonryOptions = {
    selectorItem: '.grid-item'
  };

  setupMasonry = function($grid) {
    return $grid.masonry(masonryOptions);
  };

  gridItemOnClick = function(e) {
    var $el;
    $el = $(e.currentTarget);
    $el.find(".content").toggleClass("hidden");
    return resizeBoxToVisibleContent($el);
  };

  resizeBoxToVisibleContent = function($el) {};

  getGrid = function() {
    return $(".grid");
  };

  getGridItems = function($grid) {
    return $grid.find(".grid-item");
  };

  getContent = function($gridItems) {
    return $gridItems.find(".content");
  };

  makeHidden = function($el) {
    return $el.addClass("hidden");
  };

  $(function() {
    var $content, $grid, $gridItems;
    $grid = getGrid();
    $gridItems = getGridItems($grid);
    $content = getContent($gridItems);
    makeHidden($content);
    setupMasonry($grid);
    return $gridItems.on("click", gridItemOnClick);
  });

}).call(this);
