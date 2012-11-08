class ChangeEmailedHostsToEmailedSupportersOnEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :emailed_nearby_hosts
    add_column :events, :emailed_nearby_supporters, :boolean
  end

  def self.down
    remove_column :events, :emailed_nearby_supporters
    add_column :events, :emailed_nearby_hosts, :boolean
  end
end
