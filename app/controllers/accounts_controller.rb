class AccountsController < ApplicationController
  skip_before_filter :require_accounts, :only => :new
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
    @account = Account.find(params[:id])
  end



  def update
    @account = Account.find(params[:id])
    @account.update_attributes(account_params)
    redirect_to accounts_path
  end



  def delete

  end



  def destroy

  end

    
  def account_params
    params.require(:account).permit(:access_key_id,:secret_access_key,:region)
  end
end
