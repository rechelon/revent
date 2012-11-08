class RemoveDistrictId < ActiveRecord::Migration
  def self.up
    # :district string already exists in events table
    remove_column :events, :district_id

    change_column :politicians, :district_id, :string
    rename_column :politicians, :district_id, :district
    
    add_column    :politicians, :person_legislator_id, :integer
    add_column    :politicians, :display_name, :string
    add_column    :politicians, :phone, :string
    add_column    :politicians, :email, :string
    add_column    :politicians, :address, :string
    add_column    :politicians, :state, :string
    add_column    :politicians, :postal_code, :string
    add_column    :politicians, :district_type, :string
    add_column    :politicians, :image_url, :string
    add_column    :politicians, :website, :string
    add_column    :politicians, :party, :string
    add_column    :politicians, :xml, :text
  end

  def self.down
    add_column :events, :district_id, :integer
  
    rename_column :politicians, :district, :district_id
    change_column :politicians, :district_id, :integer
    
    remove_column :politicians, :person_legislator_id
    remove_column :politicians, :display_name
    remove_column :politicians, :phone
    remove_column :politicians, :email
    remove_column :politicians, :address
    remove_column :politicians, :state
    remove_column :politicians, :postal_code
    remove_column :politicians, :district_type
    remove_column :politicians, :image_url
    remove_column :politicians, :website
    remove_column :politicians, :party
    remove_column :politicians, :xml
  end
end
