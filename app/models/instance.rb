class Instance < ActiveRecord::Base
# validates :instance_id,
#   presence: true,
#   uniqueness: true
# validates :boot_order,
#   uniqueness: { 
#     scope: :stack_id
#   }
  belongs_to :stack

  before_save :set_defaults

  def set_defaults
    stack = Stack.find(self.stack_id)
    if self.delay.nil?
      self.delay = 0
    end
    if self.id ==nil
      self.boot_order = stack.instances.length + 1
      self.delay = 0
    end
  end

end
