ready = ->
  adminLessonDraftsCalendar = $("#admin_lesson_drafts_calendar")

  adminLessonDraftsCalendar.fullCalendar($.extend({}, $.fn.fullCalendar.defaults, {
    columnFormat: 'dddd'
    header: false
    eventRender: (event, element) ->
      element.data('url', '/admin/lesson_drafts/' + event.id)
      element.attr('id', 'lesson_draft_' + event.id)
    eventClick: (calEvent, jsEvent, view) ->
      WebuiPopovers.hideAll()
      $modal = $('#lessonModal')
      $modal.find('.modal-content').load '/admin/lesson_drafts/' + calEvent.id + '/edit', ->
        $modal.modal('show')
    events: adminLessonDraftsCalendar.data('events-url')
  }))

$(document).ready(ready)