class User < ActiveRecord::Base
  REGEX = /\A[a-zA-Z]\w+\z/

  validates :username,
    presence: true,
    uniqueness: true,
    format: {:with => REGEX},
    length: {:minimum => 5, :maximum => 15}

  validates :display_name,
    presence: true,
    length: {:maximum => 50}


  has_secure_password
  
  belongs_to :company
end
