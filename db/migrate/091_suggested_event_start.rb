class SuggestedEventStart < ActiveRecord::Migration
  def self.up
    add_column :calendars, :suggested_event_start, :datetime
    Calendar.reset_column_information
    Calendar.find(:all).each do |c|
      c.update_attribute :suggested_event_start, c.event_start
    end
  end

  def self.down
    remove_column :calendars, :suggested_event_start
  end
end
