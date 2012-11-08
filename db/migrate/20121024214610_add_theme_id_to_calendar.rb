class AddThemeIdToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :theme_id, :integer
  end

  def self.down
    remove_column :calendars, :theme_id
  end
end
