class AdditionalEventFields < ActiveRecord::Migration
  def self.up
    add_column :events, "service_foreign_key", :string
    add_column :events, "latitude", :float, :precision => 10, :scale => 6
    add_column :events, "longitude", :float, :precision => 10, :scale => 6
  end

  def self.down
    remove_column :events, "service_foreign_key"
    remove_column :events, :latitude
    remove_column :events, :longitude
  end
end
