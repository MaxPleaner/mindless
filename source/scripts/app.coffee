masonryOptions =
  selectorItem: '.grid-item'

setupMasonry = ($grid) ->
  $grid.masonry masonryOptions
        
gridItemOnClick = (e) ->
  $el = $ e.currentTarget
  $el.find(".content").toggleClass "hidden"
  resizeBoxToVisibleContent($el)

resizeBoxToVisibleContent = ($el) ->
  # debugger

getGrid = () -> $ ".grid"
getGridItems = ($grid) -> $grid.find ".grid-item"
getContent = ($gridItems) -> $gridItems.find ".content"
makeHidden = ($el) -> $el.addClass "hidden"

$ () ->

  $grid = getGrid()
  $gridItems = getGridItems($grid)
  $content = getContent($gridItems)
  makeHidden($content)
  setupMasonry($grid)
  $gridItems.on "click", gridItemOnClick
    
