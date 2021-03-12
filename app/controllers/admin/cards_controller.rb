class Admin::CardsController < ApplicationController
  include AdminController

  before_action :load_user

  def update
    @user_card_updater = User::CardUpdater.new(user: @user, card_reference: user_params[:card_reference])

    if @user_card_updater.save
      redirect_to edit_admin_user_card_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = user_card_updater_flash_error
      render :edit
    end
  end

  def destroy
    @user.update_attributes(card_reference: nil)
    ResamaniaApi::PushUserWorker.perform_async(@user.id)

    redirect_to edit_admin_user_card_path, notice: t_action_flash(:notice)
  end

  def print
    respond_to do |format|
      format.pdf do
        render pdf: "card_print_#{@user.full_name}",
          layout: false,
          page_width: '85.5mm',
          page_height: '54mm',
          dpi: '300',
          show_as_html: params.key?('debug'),
          lowquality: false,
          disable_smart_shrinking: false,
          header: false,
          footer: false,
          zoom: 1.248,
          margin: { top: '0', bottom: '0', left: '0', right: '0' }
      end
    end
  end

  def force_authorization
    @user.update_attributes!(card_access: :forced_authorized)
    ResamaniaApi::PushUserWorker.perform_async(@user.id)

    redirect_to edit_admin_user_card_path, notice: t_action_flash(:notice)
  end

  private

  def user_params
    params.require(:user).permit(:card_reference)
  end

  def load_user
    @user = User.find(params[:user_id]).decorate
  end

  def user_card_updater_flash_error
    if @user_card_updater.card_reference.blank?
      t_action_flash(:card_blank_alert)
    elsif @user_card_updater.referenced_user
      referenced_user = UserDecorator.decorate(@user_card_updater.referenced_user)

      t('flash.admin.cards.update.card_already_assigned_alert',
        user_name: referenced_user.full_name,
        edit_link: (view_context.link_to(t('flash.admin.cards.update.card_already_assigned_edit_link'),
                                         edit_admin_user_card_path(referenced_user)))
      ).html_safe
    else
      t_action_flash(:alert)
    end
  end
end
