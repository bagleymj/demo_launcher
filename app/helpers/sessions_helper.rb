module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session[:user_id] = nil
    @current_user = nil
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def is_admin?
    if logged_in?
      current_user.admin
    end
  end

  def first_run?
    Account.all.empty?
  end
end
