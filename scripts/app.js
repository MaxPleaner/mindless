(function() {
  var addButtonToShowAll, bringBackiFrame, buildNavbarTagsMenu, filterGrid, gridItemOnClick, gridItemOnMouseenter, gridItemOnMouseleave, hideAllContent, isotopeFilterFn, loadInitialState, metadataOnClick, refreshGrid, resetAlliFrames, setupGrid, setupMetadata, showAllButtonOnClick, togglingContentOnMouseenter, togglingContentOnMouseleave;

  gridItemOnClick = function($grid, e) {
    var $content, $el, src;
    e.stopPropagation();
    $el = $(e.currentTarget);
    if ($grid.find(".content:not(.hidden)").length > 0) {
      hideAllContent($grid);
      resetAlliFrames();
    } else {
      $content = $($el.find(".content")[0]);
      $content.removeClass("hidden");
      src = $content.find("iframe").attr("src");
      if (!src || (src.length === 0)) {
        bringBackiFrame($el);
      }
    }
    return refreshGrid($grid);
  };

  hideAllContent = function($grid) {
    return $grid.find(".content").addClass("hidden");
  };

  isotopeFilterFn = function() {
    var currentTag, isVisible, tags;
    tags = $(this).data("tags");
    currentTag = window.currentTag;
    if (currentTag) {
      isVisible = (tags.length > 0) && tags.includes(currentTag);
    } else {
      isVisible = true;
    }
    return isVisible;
  };

  filterGrid = function($grid) {
    return $grid.isotope({
      filter: isotopeFilterFn
    });
  };

  gridItemOnMouseenter = function(e) {
    return $(e.currentTarget).addClass("selected-grid-item");
  };

  gridItemOnMouseleave = function(e) {
    return $(e.currentTarget).removeClass("selected-grid-item");
  };

  togglingContentOnMouseenter = function(e) {
    return $(e.currentTarget).parents(".grid-item").removeClass("selected-grid-item");
  };

  togglingContentOnMouseleave = function(e) {
    return $(e.currentTarget).parents(".grid-item").addClass("selected-grid-item");
  };

  setupGrid = function($grid, $gridItems, $togglingContent) {
    $gridItems.on("click", curry(gridItemOnClick)($grid));
    $togglingContent.on("click", function(e) {
      return e.stopPropagation();
    });
    $togglingContent.addClass("hidden");
    $gridItems.on("mouseenter", gridItemOnMouseenter);
    $gridItems.on("mouseleave", gridItemOnMouseleave);
    $togglingContent.on("mouseenter", togglingContentOnMouseenter);
    $togglingContent.on("mouseleave", togglingContentOnMouseleave);
    return $grid.isotope({
      itemSelector: '.grid-item',
      layoutMode: 'fitRows'
    });
  };

  refreshGrid = function($grid) {
    return $grid.isotope();
  };

  loadInitialState = function($grid) {
    var currentTag;
    currentTag = window.location.hash.replace("#", "");
    if (currentTag.length > 0) {
      window.currentTag = currentTag;
      return filterGrid($grid);
    }
  };

  metadataOnClick = function($grid, e) {
    var tag;
    tag = $(e.currentTarget).text();
    window.location.hash = tag;
    window.currentTag = tag;
    filterGrid($grid);
    return e.preventDefault();
  };

  setupMetadata = function($grid, $metadata) {
    var $navbarTagsMenu;
    $metadata.addClass("hidden");
    $navbarTagsMenu = buildNavbarTagsMenu($grid, $metadata);
    $("#nav").append($navbarTagsMenu);
    return $(".tagLink").on("click", curry(metadataOnClick)($grid));
  };

  buildNavbarTagsMenu = function($grid, $metadata) {
    var $navbarTagsMenu, tags;
    $navbarTagsMenu = $("<div id='navbarTags'></div>");
    tags = $.map($metadata, function(node) {
      var $node, nodeJson;
      $node = $(node);
      nodeJson = $node.text();
      tags = JSON.parse(nodeJson)['tags'];
      $node.parents(".grid-item").data("tags", tags);
      return tags;
    });
    tags = Array.from(new Set(tags));
    tags.forEach(function(tag) {
      var tagLink;
      tagLink = $("<a></a>").html(tag).addClass("tagLink").attr("href", "#");
      return $navbarTagsMenu.append(tagLink);
    });
    addButtonToShowAll($grid, $navbarTagsMenu);
    return $navbarTagsMenu;
  };

  addButtonToShowAll = function($grid, $navbarTagsMenu) {
    var $button;
    $button = $("<a></a>").html("all").addClass("showAllLink").attr("href", "#");
    $navbarTagsMenu.prepend($button);
    return $button.on("click", curry(showAllButtonOnClick)($grid));
  };

  showAllButtonOnClick = function($grid, e) {
    window.location.hash = "";
    window.currentTag = void 0;
    filterGrid($grid);
    return e.preventDefault();
  };

  resetAlliFrames = function() {
    return $.each($("iframe"), function(idx, node) {
      var $node, dataSrc, src;
      $node = $(node);
      src = $node.attr("src");
      dataSrc = $node.data("src");
      if (src && src.length > 1) {
        dataSrc = src;
      }
      $node.data("src", dataSrc);
      return $node.attr("src", "");
    });
  };

  bringBackiFrame = function($gridItem) {
    var $iframe;
    $iframe = $gridItem.find("iframe");
    if ($iframe) {
      resetAlliFrames();
      return $iframe.attr("src", $iframe.data("src"));
    }
  };

  $(function() {
    var $grid, $gridItems, $metadata, $togglingContent;
    $grid = $(".grid");
    $gridItems = $grid.find(".grid-item");
    $togglingContent = $gridItems.find(".content");
    $metadata = $grid.find(".metadata");
    setupMetadata($grid, $metadata);
    loadInitialState($grid);
    return setupGrid($grid, $gridItems, $togglingContent);
  });

}).call(this);
