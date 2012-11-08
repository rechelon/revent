class AddEmailedNearbyHostsFlag < ActiveRecord::Migration
  def self.up
    add_column :events, :emailed_nearby_hosts, :boolean
  end

  def self.down
    remove_column :events, :emailed_nearby_hosts
  end
end
