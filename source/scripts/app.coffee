gridItemOnClick = ($grid, e) ->
  e.stopPropagation()
  $el = $ e.currentTarget
  $($el.find(".content")[0]).toggleClass "hidden"
  refreshGrid($grid)

isotopeFilterFn = () ->
  tags = $(this).data("tags")
  currentTag = window.currentTag
  if currentTag
    isVisible = (tags.length > 0) && tags.includes(currentTag)
  else
    isVisible = true
  return isVisible

filterGrid = ($grid) ->
  $grid.isotope filter: isotopeFilterFn
  
gridItemOnMouseenter = (e) ->
  $(e.currentTarget).addClass("selected-grid-item")
  
gridItemOnMouseleave = (e) ->
  $(e.currentTarget).removeClass("selected-grid-item")

togglingContentOnMouseenter = (e) ->
  $(e.currentTarget).parent(".grid-item")
                    .removeClass("selected-grid-item")

togglingContentOnMouseleave = (e) ->
  $(e.currentTarget).parent(".grid-item")
                    .addClass("selected-grid-item")

setupGrid = ($grid, $gridItems, $togglingContent) ->
  $gridItems.on "click", curry(gridItemOnClick)($grid)
  $togglingContent.on "click", (e) -> e.stopPropagation()
  $togglingContent.addClass "hidden"
  $gridItems.on "mouseenter", gridItemOnMouseenter
  $gridItems.on "mouseleave", gridItemOnMouseleave
  $togglingContent.on "mouseenter", togglingContentOnMouseenter
  $togglingContent.on "mouseleave", togglingContentOnMouseleave
  $grid.isotope
    itemSelector: '.grid-item'
    layoutMode: 'fitRows'
  
refreshGrid = ($grid) ->
  $grid.isotope() # no need to re-supply initialization options

loadInitialState = ($grid) ->
  currentTag = window.location.hash.replace("#", "")
  if currentTag.length > 0
    window.currentTag = currentTag
    filterGrid($grid)

metadataOnClick = ($grid, e) ->
  tag = $(e.currentTarget).text()
  window.location.hash = tag
  window.currentTag = tag
  filterGrid($grid)
  e.preventDefault()

setupMetadata = ($grid, $metadata) ->
  $metadata.addClass "hidden"
  $navbarTagsMenu = buildNavbarTagsMenu($grid, $metadata)
  $("#nav").append($navbarTagsMenu)
  $(".tagLink").on "click", curry(metadataOnClick)($grid)

buildNavbarTagsMenu = ($grid, $metadata) ->
  $navbarTagsMenu = $("<div id='navbarTags'></div>")
  tags = $.map $metadata, (node) ->
    $node = $ node
    nodeJson = $node.text()
    tags = JSON.parse(nodeJson)['tags']
    $node.parent(".grid-item").data("tags", tags)
    tags
  tags.forEach (tag) ->
      tagLink = $("<a></a>").html(tag)
                            .addClass("tagLink")
                            .attr("href", "#")
      $navbarTagsMenu.append(tagLink)
  addButtonToShowAll($grid, $navbarTagsMenu)
  return $navbarTagsMenu

addButtonToShowAll = ($grid, $navbarTagsMenu) ->
  $button = $("<a></a>").html("all")
                        .addClass("showAllLink")
                        .attr("href", "#")
  $navbarTagsMenu.prepend($button)
  $button.on "click", curry(showAllButtonOnClick)($grid)
  
showAllButtonOnClick = ($grid, e) ->
  window.location.hash = ""
  window.currentTag = undefined
  filterGrid($grid)
  e.preventDefault()

$ () ->

  $grid            = $ ".grid"
  $gridItems       = $grid.find ".grid-item"
  $togglingContent = $gridItems.find ".content"
  $metadata        = $grid.find ".metadata"
  
  setupMetadata($grid, $metadata)
  loadInitialState($grid)
  setupGrid($grid, $gridItems, $togglingContent)
  
  
  
    
