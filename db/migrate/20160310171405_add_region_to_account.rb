class AddRegionToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :region, :string
  end
end
