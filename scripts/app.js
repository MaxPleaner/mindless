(function() {
  var addButtonToShowAll, bringBackiFrame, buildNavbarTagsMenu, filterGrid, finalize, gridItemOnClick, gridItemOnMouseenter, gridItemOnMouseleave, isotopeFilterFn, loadInitialState, metadataOnClick, refreshGrid, resetAlliFrames, setupGrid, setupMetadata, showAllButtonOnClick, togglingContentOnMouseenter, togglingContentOnMouseleave;

  gridItemOnClick = function($grid, e) {
    var $content, $el, $otherContentAlreadyVisible, isThisContentAlreadyVisible, src;
    e.stopPropagation();
    $el = $(e.currentTarget);
    $content = $($el.find(".content")[0]);
    isThisContentAlreadyVisible = !$content.hasClass("hidden");
    $otherContentAlreadyVisible = $grid.find(".content:not(.hidden)");
    if ($otherContentAlreadyVisible.length > 0) {
      $otherContentAlreadyVisible.addClass("hidden");
      resetAlliFrames();
    }
    if (!isThisContentAlreadyVisible) {
      $content.removeClass("hidden");
      src = $content.find("iframe").attr("src");
      if (!src || (src.length === 0)) {
        bringBackiFrame($el);
      }
    }
    return refreshGrid($grid);
  };

  isotopeFilterFn = function() {
    var currentTags, isVisible, tags;
    tags = $(this).data("tags");
    currentTags = window.currentTags || [];
    if (currentTags.some(function(tag) {
      return tag.length > 0;
    })) {
      isVisible = (tags.length > 0) && currentTags.some(function(tag) {
        return (tag.length > 0) && tags.includes(tag);
      });
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
    $grid.isotope;
    return refreshGrid($grid);
  };

  refreshGrid = function($grid) {
    return $grid.isotope({
      itemSelector: '.grid-item',
      layoutMode: 'fitRows'
    });
  };

  loadInitialState = function($grid) {
    var currentTags;
    currentTags = window.location.hash.replace("#", "").split(",");
    if (currentTags.length > 0) {
      window.currentTags = currentTags;
      filterGrid($grid);
      return window.currentTags.forEach(function(tag) {
        return $(".tagLink[tag='" + tag + "']").addClass("selectedTag");
      });
    }
  };

  metadataOnClick = function($grid, e) {
    var $node, idx, tag;
    $node = $(e.currentTarget);
    tag = $node.text();
    if ($node.hasClass("selectedTag")) {
      $node.removeClass("selectedTag");
      idx = window.currentTags.indexOf(tag);
      if (idx > -1) {
        window.currentTags.splice(idx, 1);
      }
    } else {
      $node.addClass("selectedTag");
      window.currentTags || (window.currentTags = []);
      window.currentTags.push(tag);
    }
    window.location.hash = window.currentTags.join(",");
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
      tagLink = $("<a></a>").html(tag).addClass("tagLink").attr("tag", tag).attr("href", "#");
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
    window.currentTags = void 0;
    filterGrid($grid);
    e.preventDefault();
    return $(".selectedTag").removeClass("selectedTag");
  };

  resetAlliFrames = function() {
    var $node, src;
    $node = window.$activeIframe;
    if ($node) {
      src = $node.attr("src");
      $node.data("src", src);
      return $node.removeAttr("src");
    }
  };

  bringBackiFrame = function($gridItem) {
    var $iframe;
    $iframe = $gridItem.find("iframe");
    if ($iframe) {
      resetAlliFrames();
      $iframe.attr("src", $iframe.data("src") + "&vq=tiny");
      return window.$activeIframe = $iframe;
    }
  };

  finalize = function() {
    $("#loading").remove();
    return $("#all-content").removeAttr("id");
  };

  $(function() {
    var $grid, $gridItems, $metadata, $togglingContent;
    $grid = $(".grid");
    $gridItems = $grid.find(".grid-item");
    $togglingContent = $gridItems.find(".content");
    $metadata = $grid.find(".metadata");
    setupMetadata($grid, $metadata);
    finalize();
    setupGrid($grid, $gridItems, $togglingContent);
    return loadInitialState($grid);
  });

}).call(this);
