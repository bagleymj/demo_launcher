class RemoveInstanceNameFromInstances < ActiveRecord::Migration
  def change
    remove_column :instances, :instance_name, :string
  end
end
