class CurrentCalendars < ActiveRecord::Migration
  def self.up
    add_column :calendars, :current, :boolean, :default => false
  end

  def self.down
    remove_column :calendars, :current
  end
end
