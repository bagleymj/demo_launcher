class AccountsController < ApplicationController
  def index
    @accounts = Account.all

  end



  def new
    @account = Account.new

  end



  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to accounts_path
    else
      render:new
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

    
  def account_params
    params.require(:account).permit(:access_key_id,:secret_access_key,:template_url)
  end
end
