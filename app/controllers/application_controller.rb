class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :set_raven_context
  before_action :load_announces

  # Internal: The callback executed when a user tries to access a
  # restricted action without being logged in.
  #
  # Returns nothing.
  def not_authenticated
    redirect_to login_url
  end

  # Internal: Translate a flash message based on an action/controller.
  #
  # name - The String/Sym representing the status of the action.
  #
  # Returns the String translation.
  def t_action_flash(name)
    t("flash.#{params[:controller].gsub('/', '.')}.#{params[:action]}.#{name}")
  end

  private

  # def set_raven_context
  #   Raven.user_context(id: current_user.try(:id))
  #   Raven.extra_context(rails_env: Rails.env.to_s, params: params.to_unsafe_h, url: request.url)
  # end

  # Private: Redirect the current logged in user to its account
  # root path.
  #
  # Returns nothing.
  def redirect_logged_in_user
    redirect_to account_root_path if current_user && current_user.role.user?
  end

  def load_announces
    @announces = AnnounceDecorator.decorate_collection(option_for_announce_decorator)
  end

  def option_for_announce_decorator
    Announce.current.active.for_all.select do |announce|
      (announce.group.present? && announce.group.users.include?(current_user)) || announce.group.blank?
    end
  end
end
