class AddCalendarIdToReports < ActiveRecord::Migration

  class Report < ActiveRecord::Base
    belongs_to :calendar
    belongs_to :event
  end

  def self.up
    add_column :reports, :calendar_id, :integer
    add_index :reports, :calendar_id
    Report.reset_column_information
    puts Report.count
    i = 0
    Report.all(:include => :event).each do |r|
      next if r.event.nil?
      r.calendar_id = r.event.calendar_id
      r.save!
      i = i+1
    end
    puts i.to_s + ' Reports updated'

  end

  def self.down
    remove_index :reports, :column => :calendar_id
    remove_column :reports, :calendar_id
  end
end
