class Template < ActiveRecord::Base
  belongs_to :account
  has_many :stacks
end
