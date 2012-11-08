class AddIconFieldsOntoCalendars < ActiveRecord::Migration
  def self.up
    add_column :calendars, :icon_upcoming, :text
    add_column :calendars, :icon_past, :text
    add_column :calendars, :icon_worksite, :text
  end

  def self.down
    remove_column :calendars, :icon_upcoming
    remove_column :calendars, :icon_past
    remove_column :calendars, :icon_worksite
  end
end
