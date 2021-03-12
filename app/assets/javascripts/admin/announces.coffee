ready = ->
  if $('#admin_announces_calendar').length
    $("#announce_content").redactor
      focus: true
      buttonsHide: ['html']

    $('#announce_target_link').on 'keyup change focus', (ev) ->
      $('#announce_external_link')
        .toggleClass 'disabled', !is_valid_url $(this).val()
        .prop 'disabled', !is_valid_url $(this).val()

    $( "#announce_start_at").datepicker
      altField: $(this).next()
      altFormat: "dd-mm-yy"
      changeMonth: true
      changeYear: true
      minDate: new Date()
      onClose: (selectedDate) ->
        $("#announce_end_at").datepicker "option", "minDate", selectedDate
        me = $(this).attr 'id'
        next = "#"+me+"_datepicker"
        $(next).attr 'value', selectedDate

    $( "#announce_end_at").datepicker
      altField: $(this).next()
      changeMonth: true
      changeYear: true
      minDate: new Date()
      onClose: (selectedDate) ->
        $("#announce_start_at").datepicker "option", "maxDate", selectedDate
        me = $(this).attr 'id'
        next = "#"+me+"_datepicker"
        $(next).attr 'value', selectedDate


  is_valid_url = (url) ->
    /^(http(s)?:\/\/)?(www\.)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/.test url

$(document).ready(ready)