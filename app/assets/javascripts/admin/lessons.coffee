ready = ->
  adminLessonsCalendar = $("#admin_lessons_calendar")

  adminLessonsCalendar.fullCalendar($.extend({}, $.fn.fullCalendar.defaults, {
    eventClick: (calEvent, jsEvent, view) ->
      WebuiPopovers.hideAll()
      $modal = $('#lessonModal')
      $modal.find('.modal-content').load '/admin/lessons/' + calEvent.id + '/edit', ->
        $modal.modal('show')
        initLessonDatePickers()
        synchronizeLessonDateTimeInputs()
    events: adminLessonsCalendar.data('events-url')
  }))

  synchronizeLessonDateTimeInputs = () ->
    lesson_date = $('#lesson_start_at_date_datepicker').datepicker("getDate")
    lesson_start_at_time = $('#lesson_start_at_time_timepicker').val()
    lesson_end_at_time = $('#lesson_end_at_time_timepicker').val()

    form_disabled = $('#lesson_form').data('disabled')

    $("input[data-provide=timepicker]").prop "disabled", (form_disabled || !lesson_date)

    if lesson_date
      lesson_start_at_time = moment(lesson_date).add(moment.duration(lesson_start_at_time)).format("YYYY-MM-DD HH:mm:00") if lesson_start_at_time
      lesson_end_at_time = moment(lesson_date).add(moment.duration(lesson_end_at_time)).format('YYYY-MM-DD HH:mm:00') if lesson_end_at_time
    else
      lesson_start_at_time = lesson_end_at_time = ''

    $('#lesson_start_at').val(lesson_start_at_time)
    $('#lesson_end_at').val(lesson_end_at_time)

  initLessonDatePickers = () ->
    if $('#lesson_form').length > 0
      $('input[data-provide=datepicker]').datepicker(
        minDate: '0'
        maxDate: '+1y'
        onSelect: (dateText) ->
          synchronizeLessonDateTimeInputs()
        onClose: (dateText) ->
          synchronizeLessonDateTimeInputs()
      ).on 'input', (e) ->
        synchronizeLessonDateTimeInputs()
      $('input[data-provide=timepicker]').timepicker(
        onSelect: (selectedTime) ->
          synchronizeLessonDateTimeInputs()
        onClose: (selectedTime) ->
          synchronizeLessonDateTimeInputs()
      ).on 'input', (e) ->
        synchronizeLessonDateTimeInputs()
    else
      $('input[data-provide=timepicker]').timepicker()

  $(document).on 'hidden.bs.modal', '#admin_lessons_calendar_container .modal', (e) ->  
    modalData = $(this).data('bs.modal')
    if modalData && modalData.options.remote
      $(this).removeData("bs.modal")
      $('.modal-content', this).empty();

  $(document).on 'loaded.bs.modal','#admin_lessons_calendar_container .modal', (e) ->
    initLessonDatePickers()
    synchronizeLessonDateTimeInputs()

  $(document).on 'ajax:success','#admin_lessons_calendar_container .modal form.remote_lesson_form', (e, data) ->
    if data.success
      $("#admin_lessons_calendar_container").find('.calendar').fullCalendar('refetchEvents')
      $("#lessonModal").modal('hide')
    else
      $("#lessonModal .modal-content").html(data.html_content)
      initLessonDatePickers()
      synchronizeLessonDateTimeInputs()

$(document).ready(ready)