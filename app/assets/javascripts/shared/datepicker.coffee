ready = ->
  $( "input[data-provide=birthdaypicker]").each ->
    $(this).datepicker
      altField: $(this).next()
      altFormat: "yy-mm-dd"
      changeMonth: true
      changeYear: true
      yearRange: 'c-100:c+1'

$(document).ready(ready)