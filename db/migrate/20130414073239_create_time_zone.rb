class CreateTimeZone < ActiveRecord::Migration
  def self.up
    create_table :time_zones do |t|
      t.string :name
    end
    add_column :events, :time_zone, :integer
  end

  def self.down
    drop_table :time_zones
    remove_column :events, :time_zone
  end
end
