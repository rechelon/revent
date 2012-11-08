class CalendarThemes < ActiveRecord::Migration
  def self.up
    add_column :calendars, :theme, :string
  end

  def self.down
    remove_column :calendars, :theme
  end
end
