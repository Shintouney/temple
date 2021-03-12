$("#subscription_payment_finished").on "hidden.bs.modal", ".modal", ->
    $(this).removeData("bs.modal").find('.modal-content').html('')
  .on "ajax:success", ".remote_invitation_form", (e, data) ->
    $("#invitationModal .modal-content").html(data.html_content)
