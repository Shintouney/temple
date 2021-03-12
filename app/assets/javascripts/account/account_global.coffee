ready = ->
  isMobile = (/Mobi/.test(navigator.userAgent))

  $('.lazy').Lazy()

  # POPOVER FOR LEGENDS
  $('body').webuiPopover
    selector: '.legend-popover'
    trigger:'hover'
    width: 300
    height: 400
    placement: 'bottom'
    animation: 'pop'

  # CALENDAR POPOVER
  if !isMobile
    $('.calendar').webuiPopover
      selector: 'a.fc-time-grid-event'
      trigger:'hover'
      placement: 'bottom'
      style: 'no-padding'
      animation: 'pop'
      type:'async',
      url: '/account/lessons/'
      async:
        before: (that, xhr, settings) ->
          settings.url = that.$element.data('url')
      content: (data) ->
        return  '<h5 class="m-top-none">' +data.formatted_title + '</h5><hr class="m-top-sm m-bottom-xs"/>' + data.description

  # CONFIRMATION POPOVER
  $('body').confirmation
    rootSelector: 'body'
    selector: '[data-toggle=confirmation]'

  # MODAL ROOM DESCRIPTIONS
  $('body').on 'hidden.bs.collapse show.bs.collapse', '#roomDescription', (e)->
    $(e.target).prev().find('em').toggleClass 'fa-chevron-right fa-chevron-down'

  # TOOLTIPS
  $('body').tooltip
    selector: '[data-toggle="tooltip"]'

  # MODAL LESSONS
  $("body").on "hidden.bs.modal", "#lessonModal", ->
    $(this).removeData("bs.modal").find('.modal-content').html('')
  .on "ajax:success", ".remote_lesson_booking_form", (e, data) ->
    if data.success
      window.location.reload()
    else
      $("#lessonModal .modal-content").html(data.html_content)
  .on "ajax:error", ".remote_lesson_booking_form", (e, jqXHR, textStatus, errorThrown) ->
    console.log 'jqXHR:'
    console.log jqXHR
    console.log 'textStatus:'
    console.log textStatus
    console.log 'errorThrown:'
    console.log errorThrown
    alert "Une erreur technique ne nous permet pas de réaliser cette action. Nous sommes désolés pour la gêne occasionnée. Veuillez réessayer plus tard."

$(document).ready(ready)