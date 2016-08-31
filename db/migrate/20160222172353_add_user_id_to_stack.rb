class AddUserIdToStack < ActiveRecord::Migration
  def change
    add_reference :stacks, :user
  end
end
