class SessionsController < ApplicationController
  skip_before_filter :require_login, :require_admin

  def new
    @title = "Log In"

  end



  def create
    user = User.find_by(username: params[:session][:username].downcase)
    if user &&  user.authenticate(params[:session][:password])
      log_in user
      redirect_to stacks_path
    else
      render :new
    end
  end



  def destroy

  end
end
