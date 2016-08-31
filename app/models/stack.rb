class Stack < ActiveRecord::Base
  validates :stack_name, 
    presence: true, 
    uniqueness: true,
    format: { 
      with: /\A[a-zA-Z]\w+\z/, 
      message: "Must begin with alpha character and contain only letters, numbers, and dashes" 
    }
  belongs_to :company
  belongs_to :template
end
