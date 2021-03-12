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
      type:'async'
      url: '/admin/lessons/'
      async:
        before: (that, xhr, settings) ->
          settings.url = that.$element.data('url')
      content: (data) ->
        return  '<h5 class="m-top-none">' +data.formatted_title + '</h5><hr class="m-top-sm m-bottom-xs"/>' + data.description

  # TOOLTIPS
  $('body').tooltip
    selector: '[data-toggle="tooltip"]'

  $('.fa-info-circle').tooltip
    container: 'body'

  $('select[multiple]').select2
    language: "fr",
    tags: true

$(document).ready(ready)