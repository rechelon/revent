class AddCloudMadeStyleIdToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :cloudmade_style_id, :integer, :default => 1
  end

  def self.down
    remove_column :calendars, :cloudmade_style_id
  end
end
