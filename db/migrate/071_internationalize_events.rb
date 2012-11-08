class InternationalizeEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :country_code, :integer, :default => 840   # default to United States (840)
    add_column :users, :country_code, :integer
    
    Event.update_all("country_code = 840")
    Event.update_all("country_code = 124", "postal_code REGEXP '^[A-Z][0-9][A-Z]'")
    User.update_all("country_code = 840")
    User.update_all("country_code = 124", "postal_code REGEXP '^[A-Z][0-9][A-Z]'")
  end
  
  def self.down
    remove_column :events, :country_code
    remove_column :users, :country_code
  end
end
