class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :instance_name
      t.string :instance_id

      t.references :stack
      t.timestamps null: false
    end
  end
end
