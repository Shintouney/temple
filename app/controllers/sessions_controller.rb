class SessionsController < ApplicationController
  before_action :require_login, only: [:destroy]
  before_action :require_no_login, only: [:new, :create]

  skip_before_action :verify_authenticity_token, except: [:destroy]

  layout 'login'

  # Simple redirect to avoid a 404
  # when a user refreshes the failed login page.
  def index
    redirect_to login_path
  end

  def new
    params[:session] = {}
  end

  def create
    email = params[:session_email].present? ? params[:session_email] : params[:session].present? ? params[:session][:email] : nil
    password = params[:session_password].present? ? params[:session_password] : params[:session].present? ? params[:session][:password] : nil
    remember_me = params[:session_remember_me].present? ? params[:session_remember_me] : params[:session].present? ? params[:session][:remember_me] : nil
    user = email.present? && password.present? ? login(email, password, remember_me) : nil
    if user
      redirect_back_or_to root_url
    else
      flash.now[:alert] = t_action_flash(:alert)
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_url, notice: t_action_flash(:notice)
  end

  private

  def require_no_login
    redirect_to root_path if logged_in?
  end
end
