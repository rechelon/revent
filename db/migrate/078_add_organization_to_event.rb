class AddOrganizationToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :organization, :string
  end

  def self.down
    remove_column :events, :organization
  end
end
