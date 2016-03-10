class RemoveTemplateUrlFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :template_url
  end
end
