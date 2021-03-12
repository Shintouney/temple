ready = ->  
  if $('body[data-env="development"]').length == 0 && $('#visits').length > 0

    window.VisitsPoller = {
      start: () ->
        unless this.timer == undefined
          this.stop()
        this.timer = setInterval(this.onPoll.bind(this), 3000)
      stop: () ->
        clearInterval(this.timer)
      onPoll: () ->
        $.getJSON $('#visits').data('collectionUrl'), (data) ->
          old_visit_ids = $.makeArray $('.user_visit').map () ->
            return $(this).data('visitId')
          current_visits = data

          current_visit_ids = $.map current_visits, (visit) ->
            visit['id']
          return if current_visit_ids == old_visit_ids

          added_visits = current_visits.filter (visit) -> (visit['id'] not in old_visit_ids)
          removed_visit_ids = old_visit_ids.filter (visit_id) -> (visit_id not in current_visit_ids)

          if removed_visit_ids.length > 0
            for visit_id in removed_visit_ids
              $(".user_visit[data-visit-id=#{visit_id}]").addClass('finished_visit')
            ordering.mixItUp 'filter', ':not(.finished_visit)', (state) ->
              state.$hide.remove()

          if added_visits.length > 0
            state = ordering.mixItUp('getState')
            added_visits_html = (visit.html for visit in added_visits).join('')
            ordering.mixItUp('append', $(added_visits_html).hide(), {sort: state.activeSort})
    }

    window.CardScansShortlogPoller = {
      start: () ->
        unless this.timer == undefined
          this.stop()
        this.timer = setInterval(this.onPoll.bind(this), 3000)
      stop: () ->
        clearInterval(this.timer)
      onPoll: () ->
        $.getJSON $('#card_scans_shortlog').data('collectionUrl'), (data) ->
          current_card_scans = data

          old_card_scan_ids = $.makeArray $('#card_scans_shortlog .card_scan_shortlog_item').map () ->
            return $(this).data('cardScanId')
          current_card_scan_ids = $.map current_card_scans, (card_scan) ->
            card_scan['id']
          return if current_card_scan_ids == old_card_scan_ids

          current_card_scans_html = (card_scan.html for card_scan in current_card_scans).join('')

          $('#card_scans_shortlog .card_scan_shortlog_item').remove()
          $('#card_scans_shortlog').append($(current_card_scans_html))

          added_card_scans = current_card_scans.filter (card_scan) -> (card_scan['id'] not in old_card_scan_ids)
          for card_scan in added_card_scans
            $("#card_scans_shortlog .card_scan_shortlog_item[data-card-scan-id='#{card_scan['id']}']").effect('highlight')
    }

    window.VisitsPoller.start()
    window.CardScansShortlogPoller.start()

    ordering = $('#visits').mixItUp
      load:
        sort:  if $('.user_visit').length > 0 then 'name:asc' else ''
      selectors:
        target: '.user_visit'
      callbacks:
        onMixLoad: (state) ->
          state.activeSort = 'name:asc'
          $('.dashboard-panel-user .panel-body').matchHeight({byRow:false});
        onMixEnd: () ->
          $('#visits-count').text $('.user_visit').length
          $.fn.matchHeight._update()


    $("#visits").on "ajax:before", ".finish_visit", (e, data) ->
      window.VisitsPoller.stop()
    .on "ajax:complete", ".finish_visit", (e, data) ->
      window.VisitsPoller.onPoll()
      window.VisitsPoller.start()
    .on 'mouseenter', '.user_visit', () ->
      window.VisitsPoller.stop()
    .on 'mouseleave', '.user_visit', () ->
      window.VisitsPoller.start()

    $("#new_visit").on "ajax:before", "#new_visit_form", (e, data) ->
      window.VisitsPoller.stop()
    .on "ajax:complete", "#new_visit_form", (e, data) ->
      window.VisitsPoller.start()
    .on "ajax:success", "#new_visit_form", (e, data) ->
      if data.success
        window.VisitsPoller.onPoll()
        $('#flash').fadeOut()
        $('#new_visit_form input:not([type=submit])').val('')
        $('#visit_location').val($('#visits').data('location'))
      else
        flash_html = $(data.flash).children().first()

        unless $('#flash').length > 0
          $('<div id="flash"></div>').prependTo('#main-container')

        $('#flash').fadeOut 'default', ->
          $(this).html('').append(flash_html).fadeIn()

    $('#users_with_autocomplete').autocomplete(
      minLength: 2
      source: (request, response) ->
        $.ajax
          url: $('#users_with_autocomplete').data('autocompleteurl')
          dataType: "json"
          data:
            name: request.term
          success: (data) ->
            response(data)
      select: (event, ui) ->
        $('#visit_user_id').val(ui.item.id)
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      $("<li>").append(item.link).appendTo ul

$(document).ready(ready)