class AddShowMapToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :show_map, :boolean, :default=>true
  end

  def self.down
    remove_column :events, :show_map
  end
end
