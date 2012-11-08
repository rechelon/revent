class AddCityToPolitician < ActiveRecord::Migration
  def self.up
    add_column :politicians, :city, :string
    add_column :politicians, :contact_state, :string
    Politician.reset_column_information
    Politician.update_all "contact_state = state"
  end
  
  def self.down
    remove_column :politicians, :city
    remove_column :politicians, :contact_state
  end
end
