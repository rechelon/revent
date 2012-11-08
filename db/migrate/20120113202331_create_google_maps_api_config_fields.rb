class CreateGoogleMapsApiConfigFields < ActiveRecord::Migration
  def self.up
    add_column :hosts, :google_maps_api_key, :string, :default => nil
  end

  def self.down
    remove_column :hosts, :google_maps_api_key
  end
end
