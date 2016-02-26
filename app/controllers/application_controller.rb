class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_filter :require_login, :require_admin

  private

    def require_login
      if !logged_in?
        redirect_to login_path
      end
    end

    def require_admin
      if !is_admin?
        redirect_to stacks_path
      end
    end


end
