class AddDiaTriggerGroupKeysToCalendars < ActiveRecord::Migration
  def self.up
    add_column :calendars, :host_dia_trigger_key, :integer
    add_column :calendars, :host_dia_group_key, :integer
  end

  def self.down
    remove_column :calendars, :host_dia_trigger_key
    remove_column :calendars, :host_dia_group_key
  end
end
