nextLessonIdReserved = null;

ready = ->
  nextLessonIdReserved = $('.calendar').data('events-current-lesson-id')
  $.fn.fullCalendar.defaults = {
    timezone: 'Europe/Paris'
    defaultView: 'agendaWeek'
    locale: 'fr'
    minTime: '07:00:00'
    maxTime: '23:00:00'
    slotEventOverlap: false
    allDaySlot: false
    height: 'auto'
    header:
        left: 'prev today'
        center: "title"
        right: "month,agendaWeek,agendaFiveDay,agendaDay next"
    eventLimit: true
    views:
      agendaFiveDay:
        type: 'agenda'
        duration:
          days: 5
        buttonText: $('data-i18n-calendarFiveDays').data();
    loading: (isLoading, view) ->
      if isLoading
        window.fullcalendar_loading = true
    eventAfterAllRender: (view) ->
      window.fullcalendar_loading = false
    eventDataTransform: (event) ->
      event.className = roomClass(event)
      return event
    eventRender: (event, element) ->
      element.data('url', '/admin/lessons/' + event.id)
      element.attr('id', 'lesson_' + event.id)
    eventAfterRender: (event, element, view) ->
      if view.name is "agendaWeek" or view.name is "agendaFiveDay" or view.name is "agendaDay"
        if event.room == '1' or event.room =='4' or event.room == '5' or event.room == '6'
          return element.css
            right: "67%"
            left: "1%"
        else if event.room == '2'
          return element.css
            right: "33%"
            left: "34%"
        else
          return element.css
            right: "1%"
            left: "68%"
  }

  roomClass = (event) ->
    cssClass = []

    switch event.room
      when "1"
        cssClass.push('calendar-boxing-ring')
      when "2"
        cssClass.push('calendar-punching-bag')
      when "3"
        cssClass.push('calendar-arsenal')
      when "4"
        cssClass.push('calendar-boxing-ring-no-opposition')
      when "5"
        cssClass.push('calendar-boxing-ring-no-opposition_advanced')
      when "6"
        cssClass.push('calendar-boxing-ring-feet-and-fist')
      else
        cssClass.push('bg-danger')

    if !event.available
      cssClass.push('calendar-full-lesson')

    if nextLessonIdReserved == event.id
      cssClass.push('calendar-booked-lesson')

    return cssClass.join(' ')

$(document).ready ready