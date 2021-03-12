ready = ->
  if $('#new_suspended_subscription_schedule').length > 0
    $('#subscription_restart_datepicker').datepicker
      minDate: '+0d'
      maxDate: '+1y'

    $('#suspension_start_datepicker').datepicker
      minDate: '+1d'
      maxDate: '+1y'

$(document).ready(ready)