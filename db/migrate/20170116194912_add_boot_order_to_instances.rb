class AddBootOrderToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :boot_order, :integer
    add_column :instances, :delay, :integer
  end
end
