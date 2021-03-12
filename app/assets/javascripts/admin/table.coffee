ready = ->
  $('table[data-sortable=true] tbody').sortable(
    handle: '.fa-arrows'
    cursor: 'move'
    update: (event, ui) ->
      $.ajax
        url: $(@).parent().data('sortable-url')
        type: "post"
        data: $(@).sortable('serialize')
        dataType: 'script'
        success: ->
          ui.item.effect( "highlight" )
  ).disableSelection()

$(document).ready(ready)