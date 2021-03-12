ready = ->
  clean_href = (link_href) ->
    href = link_href.attr('href')
    link_href.attr 'href', href.replace(/&.+/, '')

  update_href = (link_href, date_start, date_end) ->
    href = link_href.attr('href')
    link_href.attr 'href', (href + '&export[date_start]=' + date_start+ '&export[date_end]=' + date_end)

  max_or_today = (selectedDate) ->
    max = moment(selectedDate, 'DD/MM/YYYY').add(2, 'months')
    if max > moment()
      max = moment()
    return max

  update_visits_href = (link_href, date_start, date_end) ->
    href = link_href.attr('href')
    link_href.attr 'href', (href + '&visits_date_start=' + date_start+ '&visits_date_end=' + date_end)

  max_or_today_visits = (selectedDate) ->
    max = moment(selectedDate, 'DD/MM/YYYY').add(1, 'months')
    if max > moment()
      max = moment()
    return max

  refresh_dl_link = (invoice_export, export_type, export_progress) ->
    attemps_left = 5
    progressrefreshlink = setInterval(->
      if attemps_left > 0
        $.ajax
          url: "/admin/exports/refresh_link?export[subtype]=#{invoice_export}&export[type]=#{export_type}"
          dataType: 'json'
          cache: false
          complete: (data) ->
            if data.responseJSON.success
              clearInterval(progressrefreshlink)
              export_progress.parent('.progress').remove()
              if $("#dl_#{ invoice_export }").length
                $("#dl_#{ invoice_export }").attr 'href', data.responseJSON.url
                $("#dl_#{ invoice_export }").html "&nbsp;&nbsp;<em class='fa fa-file-excel-o'></em> #{ data.responseJSON.name }"
              else
                link = $("<a class='btn btn-block btn-primary btn-xs m-top-sm' style='display: block' href=#{data.responseJSON.url} id='dl_#{invoice_export}'><em class='far fa-file-excel'></em> #{data.responseJSON.name}</a>")
                $("#dl_#{invoice_export}_link_wrapper").append(link)
            else
              attemps_left = attemps_left - 1
          error: (jqXHR, textStatus, errorThrown) ->
            console.log 'jqXHR:'
            console.log jqXHR
            console.log 'textStatus:'
            console.log textStatus
            console.log 'errorThrown:'
            console.log errorThrown
      else
        clearInterval(progressrefreshlink)
    , 2000)

  track_progress = (invoice_export) ->
    if invoice_export == 'default'
      export_type = 'lesson_booking'
    else if invoice_export == 'debit'
      export_type = 'payment'
    else if invoice_export == 'active' || invoice_export == 'inactive' || invoice_export == 'reporting'
      export_type = 'user'
    else
      export_type = 'invoice'

    export_progress = $("#progress_#{invoice_export}")
    if export_progress.length > 0
      export_button = $("##{invoice_export}_#{export_type}s_export")
      progresspump = setInterval(->
        $.ajax
          url: "/admin/exports/#{export_progress.attr('data-id')}/progress"
          dataType: 'json'
          cache: false
          complete: (data) ->
            export_progress.css("width", "#{data.responseText}%")
            export_progress.html("#{parseInt(data.responseText)}%")
            export_progress.attr('aria-valuenow', data.responseText)
            if data.responseText > 99.999
              clearInterval progresspump
              refresh_dl_link(invoice_export, export_type, export_progress)
          error: (jqXHR, textStatus, errorThrown) ->
            console.log 'jqXHR:'
            console.log jqXHR
            console.log 'textStatus:'
            console.log textStatus
            console.log 'errorThrown:'
            console.log errorThrown
            clearInterval progresspump
      , 2000)

  if $("#accounting").length
    track_progress invoice_export for invoice_export in ['finished', 'unfinished', 'special', 'default', 'debit', 'active', 'inactive', 'reporting']

    if $('#flash').length
      setTimeout (->
        $('#flash').slideUp 'normal', ->
          $(this).empty()
      ), 4000

    # Accounting
    $('#articles_export').on 'click', (ev) ->
      date_start = $("#accounting input#date_start").val()
      date_end = $("#accounting input#date_end").val()
      clean_href($(this))
      update_href($(this), date_start, date_end)

    $("#finished_invoices_export, #unfinished_invoices_export, #special_invoices_export, #default_lesson_bookings_export, #debit_payments_export, #active_users_export, #inactive_users_export, #reporting_users_export"). on 'click', (ev) ->
      date_start = $("#accounting input#date_start").val()
      date_end = $("#accounting input#date_end").val()
      for start_input in $("input[name='export[date_start]']")
        start_input.value = date_start
      for end_input in $("input[name='export[date_end]']")
        end_input.value = date_end

    $("#accounting input#date_start.birthdaypicker").datepicker
      altField: $(this).next()
      altFormat: "dd-mm-yy"
      changeMonth: true
      changeYear: true
      minDate: new Date('2013-01-01')
      numberOfMonths: 2
      maxDate: '0m'
      onClose: (selectedDate) ->
        $("#accounting input#date_start").attr("value", selectedDate)
        $("#accounting #date_end").datepicker "option",
          minDate: selectedDate
          maxDate: max_or_today(selectedDate).format('DD/MM/YYYY')

    $("#accounting input#date_end.birthdaypicker").datepicker
      changeMonth: true
      changeYear: true
      minDate: new Date('2013-01-01')
      numberOfMonths: 2
      maxDate: '0m'
      onClose: (selectedDate) ->
        $("#accounting input#date_end").attr("value", selectedDate)
        if selectedDate is ""
          $("#accounting #date_start").datepicker "option", "minDate", null
        else
          $("#accounting #date_start").datepicker "option",
            maxDate: selectedDate
            minDate: moment(selectedDate, 'DD/MM/YYYY').subtract(2, 'months').format('DD/MM/YYYY')

  if $("#visits_export").length

    # Visits
    $('#visits_export').on 'click', (ev) ->
      date_start = $("#visiting input#visits_date_start").val()
      date_end = $("#visiting input#visits_date_end").val()
      clean_href($(this))
      update_visits_href($(this), date_start, date_end)

    $("#visiting input#visits_date_start.birthdaypicker").datepicker
      altField: $(this).next()
      altFormat: "dd-mm-yy"
      changeMonth: true
      changeYear: true
      minDate: new Date('2014-01-01')
      maxDate: '0d'
      onClose: (selectedDate) ->
        $("#visiting #visits_date_end").datepicker "option",
          'minDate': selectedDate
          'maxDate': max_or_today_visits(selectedDate).format('DD/MM/YYYY')

    $("#visiting input#visits_date_end.birthdaypicker").datepicker
      changeMonth: true
      changeYear: true
      minDate: new Date('2014-01-01')
      maxDate: '+1m'
      onClose: (selectedDate) ->
        if selectedDate is ""
          $("#visiting #visits_date_start").datepicker "option", "minDate", new Date('2014-01-01')
        else
          $("#visiting #visits_date_start").datepicker "option",
            maxDate: selectedDate
            minDate: moment(selectedDate, 'DD/MM/YYYY').subtract(1, 'months').format('DD/MM/YYYY')

  $('.clear_datepicker').on 'click', () ->
    datePickers = $(this).parent().find(':text')
    datePickers.datepicker 'setDate', null
    datePickers.datepicker 'option',
      minDate: new Date('2013-01-01')
      maxDate: new Date()
    datePickers.datepicker 'refresh'

$(document).ready(ready)