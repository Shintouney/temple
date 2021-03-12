class HomeController < ApplicationController
  def index
    if !current_user
      redirect_to login_path
    elsif current_user.role.admin? || current_user.role.staff?
      redirect_to admin_root_path
    else
      redirect_to account_root_path
    end
  end
end
