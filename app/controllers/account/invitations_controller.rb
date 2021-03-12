class Account::InvitationsController < ApplicationController
  include AccountController

  before_action :build_invitation_form

  def new
    render 'new_modal', layout: false
  end

  def create
    if @invitation_form.valid?
      UserMailer.invite_friend(current_user.id, invitation_form_params[:to], invitation_form_params[:text]).deliver_later

      render json: {
        success: true,
        html_content: render_to_string('created_modal', layout: false)
      }
    else
      render json: {
        success: false,
        html_content: render_to_string('new_modal', layout: false)
      }
    end
  end

  private

  def build_invitation_form
    @invitation_form = InvitationForm.new(invitation_form_params)
  end

  def invitation_form_params
    if params.key?(:invitation_form)
      params.require(:invitation_form).permit(:to, :text)
    else
      {}
    end
  end
end
