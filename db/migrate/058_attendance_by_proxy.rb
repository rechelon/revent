class AttendanceByProxy < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :proxy, :boolean
  end

  def self.down
    remove_column :rsvps, :proxy
  end
end
