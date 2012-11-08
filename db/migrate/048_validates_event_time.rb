class ValidatesEventTime < ActiveRecord::Migration
  def self.up
    add_column :calendars, :event_start, :datetime
    add_column :calendars, :event_end, :datetime
  end

  def self.down
    remove_column :calendars, :event_start
    remove_column :calendars, :event_end
  end
end
