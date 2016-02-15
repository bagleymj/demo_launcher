class Account < ActiveRecord::Base
  def account_params
    params.require(:account).permit(:access_key_id,:secret_access_key,:template_url)
  end
end
