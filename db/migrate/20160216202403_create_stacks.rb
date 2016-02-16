class CreateStacks < ActiveRecord::Migration
  def change
    create_table :stacks do |t|
      t.string :stack_id
      t.string :stack_name

      t.timestamps null: false
    end
  end
end
