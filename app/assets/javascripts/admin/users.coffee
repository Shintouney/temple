ready = ->

  $force_access = $('#force_access')
  $forbid_access = $('#forbid_access')

  $('.access-toggler').on 'change', () ->
    checked_access = $(this).attr('id')

    if checked_access=='force_access'
      # First toggle opposite switch if needed.
      if $force_access.prop('checked') && $forbid_access.prop('checked')
        $forbid_access.bootstrapToggle('off')

    else if checked_access=='forbid_access'
      # First toggle opposite switch if needed.
        if $forbid_access.is(':checked') && $force_access.is(':checked')
          $force_access.bootstrapToggle('off')

    $.ajax
      type: 'POST'
      url: $(this).data('path')
      data: { state: $(this).prop('checked') }
      dataType: 'json'
      success: (data) ->
        has_mandate = $("#access-mandate").data('state')
        has_payments = $("#access-payments").data('state')

        if data.force == true
          access = true
        else if data.forbid == true
          access = false
        else if has_mandate && has_payments
          access = true
        else
          access = false

        $('#access_planning strong')
          .eq(0).toggleClass 'hide', !access
          .end()
          .eq(1).toggleClass 'hide', access

  $('#payment_mode').on 'change', () ->
    $this = $(@)
    payment_mode = $this.prop('checked') ? 'cb' : 'sepa'

    $.ajax
      type: 'PATCH'
      url: $this.data('path')
      dataType: 'json'
      data: { payment_mode: payment_mode }
      complete: (data) ->
        answer = JSON.parse(data.responseText)
        if answer['status'] != 200
          $('#payment_mode').parents('.form-group').append("<p class='text-danger'>"+answer['errors']+"</p>")

$(document).ready(ready)