class AddDefaultCategoryIdToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :default_category_id, :int
  end

  def self.down
    remove_column :calendars, :default_category_id
  end
end
