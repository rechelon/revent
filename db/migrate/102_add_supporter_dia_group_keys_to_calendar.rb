class AddSupporterDiaGroupKeysToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :supporter_dia_group_keys, :string
  end

  def self.down
    remove_column :calendars, :supporter_dia_group_keys
  end
end
