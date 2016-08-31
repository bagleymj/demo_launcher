class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :template_name
      t.string :template_url
      t.references :account, :index => true, :foreign_key => true

      t.timestamps null: false
    end
  end
end
