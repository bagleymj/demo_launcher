class UsersController < ApplicationController
  def index
    @users = User.all
  end



  def new
    @title = "New User"
    @user = User.new

  end



  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      flash[:danger] = @user.errors.full_messages
      render :new
    end
  end

  def edit
    @title = "Edit User"
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to users_path
    else
      flash[:danger] == @user.errors.full_messages
    end

  end

  

  def user_params
    params.require(:user).permit(:username, :display_name, :company_name, :password, :password_confirmation, :admin)

  end
end
