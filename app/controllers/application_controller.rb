class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_filter :set_header, :require_login, :require_admin, :require_accounts


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

    def require_accounts
      if Account.all.empty?
        redirect_to new_account_path
        flash[:banner] = "It looks like it's your first time here.  Please set up an AWS account to get started."
      end
    end

    def set_header
      @header_items = ['Stacks','Accounts','Templates','Users']
    end


end
