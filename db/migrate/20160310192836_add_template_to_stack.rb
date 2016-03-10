class AddTemplateToStack < ActiveRecord::Migration
  def change
    add_reference :stacks, :template, index: true, foreign_key: true
  end
end
