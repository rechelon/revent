class AddEventExpirationToCalendars < ActiveRecord::Migration
  def self.up
    add_column :calendars, :days_before_event_expiration, :integer
  end

  def self.down
    remove_column :calendars, :days_before_event_expiration
  end
end
