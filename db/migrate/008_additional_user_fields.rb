class AdditionalUserFields < ActiveRecord::Migration
  def self.up
    add_column "users", :first_name, :string
    add_column "users", :last_name, :string
    add_column "users", :phone, :string
    add_column "users", :street, :string
    add_column "users", :street_2, :string
    add_column "users", :city, :string
    add_column "users", :state, :string
    add_column "users", :postal_code, :string
  end

  def self.down
    remove_column "users", :first_name, :string
    remove_column "users", :last_name, :string
    remove_column "users", :phone, :string
    remove_column "users", :street, :string
    remove_column "users", :street_2, :string
    remove_column "users", :city, :string
    remove_column "users", :state, :string
    remove_column "users", :postal_code, :string
  end
end
