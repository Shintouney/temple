ready = ->
  #$(@).addClass 'opened'

  #Collapsible Sidebar Menu
  $(document).on 'click', '.openable > a', (e) ->
    e.preventDefault()
    e.stopPropagation()
    e.stopImmediatePropagation()
    $('ul.submenu.block').not($(@).next()).slideUp ->
      $(@).removeClass 'block'
    $(@).next('ul.submenu').slideToggle ->
      $(@).toggleClass 'block'

  #Toggle Menu for smartphone
  $(document).on 'click', '#sidebarToggle', (e) ->
    e.preventDefault()
    e.stopPropagation()
    e.stopImmediatePropagation()
    $("#wrapper").toggleClass 'sidebar-display'

$(document).ready(ready)