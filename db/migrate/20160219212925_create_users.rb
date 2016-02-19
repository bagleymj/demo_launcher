class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :display_name
      t.string :company_name
      t.string :password

      t.timestamps null: false
    end
  end
end
