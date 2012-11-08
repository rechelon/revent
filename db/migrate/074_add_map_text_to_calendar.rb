class AddMapTextToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :map_intro_text, :text
  end
  
  def self.down
    remove_column :calendars, :map_intro_text
  end
end
