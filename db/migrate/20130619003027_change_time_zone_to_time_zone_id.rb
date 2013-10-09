class ChangeTimeZoneToTimeZoneId < ActiveRecord::Migration
  def self.up
    rename_column :events, :time_zone, :time_zone_id
  end

  def self.down
    rename_column :events, :time_zone_id, :time_zone
  end
end
