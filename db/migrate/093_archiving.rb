class Archiving < ActiveRecord::Migration
  def self.up
    add_column :events, :reports_enabled, :boolean, :default => true
    add_column :calendars, :archived, :boolean, :default => false
    Event.reset_column_information
    Event.update_all ["reports_enabled=?", true]
    Calendar.reset_column_information
    Calendar.update_all ["archived = ?", false]
  end

  def self.down
    remove_column :calendars, :archived
    remove_column :events, :reports_enabled
  end
end
