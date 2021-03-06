class UsersController < ApplicationController
  skip_before_filter :require_admin, :only => :edit

  def index
    @title = "User List"
    @users = User.all
  end



  def new
    @title = "New User"
    @user = User.new
    @companies = Company.all
  end



  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      flash[:danger] = @user.errors.full_messages
      redirect_to new_user_path
    end
  end

  def edit
    @title = "Edit User"
    if is_admin?
      @user = User.find(params[:id])
    else
      @user = User.find(@current_user.id)
    end
    @companies = Company.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to users_path
    else
      flash[:danger] = @user.errors.full_messages
    end

  end

  def destroy
    @user = User.find(params[:id])
    if @user.stacks.all.empty?
      @user.destroy
      redirect_to users_path
    else
      flash[:danger] = "The user, #{@user.display_name}, has active stacks, 
                        please delete them before deleting this user."
      redirect_to users_path
    end
  end


  

  def user_params
    params.require(:user).permit(:username, :display_name, :company_id, :password, :password_confirmation, :admin)

  end
end
