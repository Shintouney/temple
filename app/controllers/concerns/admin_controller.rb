# encoding: UTF-8
module AdminController
  extend ActiveSupport::Concern

  included do
    before_action :require_login, :require_admin
    skip_before_action :load_announces

    layout 'admin'
  end

  private

  def require_admin
    return if current_user.role.admin? || current_user.role.staff?
    redirect_to root_path, alert: t('flash.access_denied')
  end

  def send_csv(csv_string)
    bom = "\xEF\xBB\xBF"
    data = "#{bom}#{csv_string}"
    options = {
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment",
      filename: @filename       
    }
    send_data(data, options)
  end
end
