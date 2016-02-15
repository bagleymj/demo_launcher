class AccountsController < ApplicationController
  def index
    @accounts = Account.all

  end



  def new
    @account = Account.new

  end



  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_to accounts_path
    else
      render :new
    end
  end
  
  

  def show

  end



  def edit

  end



  def update

  end



  def delete

  end



  def destroy

  end

end
