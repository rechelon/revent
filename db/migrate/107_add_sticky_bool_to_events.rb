class AddStickyBoolToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :sticky, :boolean
  end

  def self.down
    remove_column :events, :sticky
  end
end
