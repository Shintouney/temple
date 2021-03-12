ready = ->
  adminLessonTemplatesCalendar = $("#admin_lesson_templates_calendar")

  adminLessonTemplatesCalendar.fullCalendar($.extend({}, $.fn.fullCalendar.defaults, {
    columnFormat: 'dddd'
    header: false
    eventRender: (event, element) ->
      element.data('url', '/admin/lesson_templates/' + event.id)
      element.attr('id', 'lesson_template_' + event.id)
    eventClick: (calEvent, jsEvent, view) ->
      WebuiPopovers.hideAll()
      $modal = $('#lessonModal')
      $modal.find('.modal-content').load '/admin/lesson_templates/' + calEvent.id + '/edit', ->
        $modal.modal('show')
    events: adminLessonTemplatesCalendar.data('events-url')
  }))

$(document).ready(ready)