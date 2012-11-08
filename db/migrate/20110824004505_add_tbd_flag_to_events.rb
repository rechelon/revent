class AddTbdFlagToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :time_tbd, :boolean, :default => false
  end

  def self.down
    remove_column :events, :time_tbd
  end
end
