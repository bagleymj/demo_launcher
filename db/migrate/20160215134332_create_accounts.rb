class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :access_key_id
      t.string :secret_access_key
      t.string :template_url

      t.timestamps null: false
    end
  end
end
