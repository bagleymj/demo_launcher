class AddCompanyReferenceToStack < ActiveRecord::Migration
  def change
    #Remove Company Name from User Table
    #Add Company Reference to User Table
    change_table :users do |t|
      t.remove :company_name
      t.references :company
    end

    #Remove User Reference from Stack Table
    #Add Company Reference to Stack Table
    change_table :stacks do |t|
      t.remove :user_id
      t.references :company
    end


  end
end
