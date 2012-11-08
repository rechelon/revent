class AddEmailToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :admin_email, :string
  end
  
  def self.down
    remove_column :calendars, :admin_email
  end
end
