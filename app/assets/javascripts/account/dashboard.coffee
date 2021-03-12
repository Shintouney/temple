ready = ->
  accountDashboardCalendar = $("#account_dashboard_calendar")

  accountDashboardCalendar.fullCalendar($.extend({}, $.fn.fullCalendar.defaults, {
    defaultView: 'agendaDay'
    header: false
    columnFormat:'dddd D MMMM'
    events: accountDashboardCalendar.data('events-url')
    eventRender: (event, element) ->
      element.data('url', '/lessons/' + event.id + '.json')
      element.attr('id', 'lesson_' + event.id)
    eventClick: (calEvent, jsEvent, view) ->
      WebuiPopovers.hideAll()
      $('#lessonModal .modal-content').load('/lessons/' + calEvent.id)
      $('#lessonModal').modal 'show'
  }))

  if $('#next_lesson_booking_panel').data('lessonUrl')
    $('#next_lesson_booking_panel').click (e) ->
      $('#lessonModal .modal-content').load($(this).data('lessonUrl'))
      $('#lessonModal').modal('show')

$(document).ready(ready)