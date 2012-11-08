class AddSupressEndTimeToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :supress_end_time, :boolean
  end

  def self.down
    remove_column :events, :supress_end_time
  end
end
