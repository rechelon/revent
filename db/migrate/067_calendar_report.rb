class CalendarReport < ActiveRecord::Migration
  def self.up
  	add_column :calendars, :rsvp_redirect, :string
    add_column :calendars, :report_redirect, :string
    add_column :calendars, :report_title_text, :string
    add_column :calendars, :report_intro_text, :text
   
  end

  def self.down
  	remove_column :calendars, :rsvp_redirect
    remove_column :calendars, :report_redirect
    remove_column :calendars, :report_title_text
    remove_column :calendars, :report_intro_text
  end
end
