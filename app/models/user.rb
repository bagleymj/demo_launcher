class User < ActiveRecord::Base
  REGEX = /A\A[a-zA-Z]\w+\z/
  validates :company_name, 
    presence: true,
    format: {:with => REGEX}

  validates :username,
    presence: true,
    uniqueness: true,
    format: {:with => REGEX},
    length: {:minimum => 5, :maximum => 15}

  validates :display_name,
    presence: true,
    length: {:maximum => 50}

  validates :admin,
    presence: true

  has_secure_password
  
  has_many :stacks
end
