module AccountController
  extend ActiveSupport::Concern

  included do
    before_action :require_login, :require_user

    layout 'account'
  end

  private

  def require_user
    return if current_user.role.user?
    redirect_to root_path, alert: t('flash.access_unavailable')
  end
end
