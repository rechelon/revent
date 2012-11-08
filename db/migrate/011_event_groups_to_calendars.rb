class EventGroupsToCalendars < ActiveRecord::Migration
  def self.up
    rename_table "event_groups", "calendars"
    rename_column "events", "event_group_id", "calendar_id"
  end

  def self.down
    rename_table "calendars", "event_groups"
    rename_column "events", "calendar_id", "event_group_id"
  end
end
