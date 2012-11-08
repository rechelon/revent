class AddMapEngineToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :map_engine, :string, :default => "gmaps"
  end

  def self.down
    remove_column :calendars, :map_engine
  end
end
