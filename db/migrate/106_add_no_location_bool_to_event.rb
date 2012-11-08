class AddNoLocationBoolToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :locationless, :boolean
  end

  def self.down
    remove_column :events, :locationless
  end
end
