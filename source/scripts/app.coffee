gridItemOnClick = ($grid, e) ->
  e.stopPropagation()
  $el = $ e.currentTarget
  $content = $ $el.find(".content")[0]
  if $grid.find(".content:not(.hidden)").length > 0
    contentAlreadyHidden = $content.hasClass "hidden"
    hideAllContent $grid
    resetAlliFrames()
    if contentAlreadyHidden
      $content.removeClass "hidden"
  else
    $content.removeClass "hidden"
    src = $content.find("iframe").attr "src"
    if !src || (src.length == 0)
      bringBackiFrame $el
  refreshGrid $grid
  
hideAllContent = ($grid) ->
  $grid.find(".content").addClass "hidden"
  
isotopeFilterFn = () ->
  tags = $(this).data "tags"
  currentTags = window.currentTags || []
  if currentTags.some((tag) -> tag.length > 0)
    isVisible = (tags.length > 0) && currentTags.some( (tag) -> (tag.length > 0) && tags.includes(tag) )
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
  $(e.currentTarget).parents(".grid-item")
                    .removeClass("selected-grid-item")

togglingContentOnMouseleave = (e) ->
  $(e.currentTarget).parents(".grid-item")
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
  refreshGrid($grid)
  
refreshGrid = ($grid) ->
  $grid.isotope
    itemSelector: '.grid-item'
    layoutMode: 'fitRows'

loadInitialState = ($grid) ->
  currentTags = window.location.hash.replace("#", "").split(",")
  if currentTags.length > 0
    window.currentTags = currentTags
    filterGrid $grid
    window.currentTags.forEach (tag) ->
      $grid.find(".tagLink[data-tag='#{tag}']").addClass("selectedTag")

metadataOnClick = ($grid, e) ->
  $node = $ e.currentTarget
  tag = $node.text()
  if $node.hasClass("selectedTag")
    $node.removeClass("selectedTag")
    idx = window.currentTags.indexOf tag
    if idx > -1
      window.currentTags.splice(idx, 1)
  else
    $node.addClass("selectedTag")
    window.currentTags ||= []
    window.currentTags.push tag
  window.location.hash = window.currentTags.join(",")
  filterGrid $grid
  e.preventDefault()

setupMetadata = ($grid, $metadata) ->
  $metadata.addClass "hidden"
  $navbarTagsMenu = buildNavbarTagsMenu $grid, $metadata
  $("#nav").append $navbarTagsMenu
  $(".tagLink").on "click", curry(metadataOnClick)($grid)

buildNavbarTagsMenu = ($grid, $metadata) ->
  $navbarTagsMenu = $ "<div id='navbarTags'></div>"
  tags = $.map $metadata, (node) ->
    $node = $ node
    nodeJson = $node.text()
    tags = JSON.parse(nodeJson)['tags']
    $node.parents(".grid-item").data "tags", tags
    tags
  tags = Array.from(new Set(tags))
  tags.forEach (tag) ->
      tagLink = $("<a></a>").html(tag)
                            .addClass("tagLink")
                            .data("tag", tag)
                            .attr("href", "#")
      $navbarTagsMenu.append tagLink
  addButtonToShowAll $grid, $navbarTagsMenu
  return $navbarTagsMenu

addButtonToShowAll = ($grid, $navbarTagsMenu) ->
  $button = $("<a></a>").html("all")
                        .addClass("showAllLink")
                        .attr("href", "#")
  $navbarTagsMenu.prepend $button
  $button.on "click", curry(showAllButtonOnClick)($grid)
  
showAllButtonOnClick = ($grid, e) ->
  window.location.hash = ""
  window.currentTags = undefined
  filterGrid $grid
  e.preventDefault()
  
resetAlliFrames = () ->
  $node = window.$activeIframe
  if $node
    src = $node.attr "src"
    $node.data "src", src
    $node.removeAttr "src"
  
bringBackiFrame = ($gridItem) ->
  $iframe = $gridItem.find "iframe"
  if $iframe
    resetAlliFrames()
    $iframe.attr "src", ($iframe.data("src") + "&vq=tiny")
    window.$activeIframe = $iframe
  
$ () ->

  $grid            = $ ".grid"
  $gridItems       = $grid.find ".grid-item"
  $togglingContent = $gridItems.find ".content"
  $metadata        = $grid.find ".metadata"
  
  setupMetadata $grid, $metadata
  loadInitialState $grid
  setupGrid $grid, $gridItems, $togglingContent

    
