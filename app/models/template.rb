class Template < ActiveRecord::Base
  belongs_to :account
  has_many :stacks
  
  before_save :default_values
  
  def default_values
    self.account_id = Account.first.id
  end

end
