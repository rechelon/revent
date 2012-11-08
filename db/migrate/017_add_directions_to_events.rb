class AddDirectionsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :directions, :string
  end

  def self.down
    remove_column :events, :directions
  end
end
