class AddNameToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :name, :string
    add_index :sites, :name
  end

  def self.down
    remove_index :sites, :column => :name
    remove_column :sites, :name
  end
end
