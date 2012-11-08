class PublishSetting < ActiveRecord::Migration
  def self.up
    add_column :calendars, :auto_publish_reports, :boolean
    Calendar.update_all( [ "auto_publish_reports = ?", true ] )
  end

  def self.down
    remove_column :calendars, :auto_publish_reports
  end
end
