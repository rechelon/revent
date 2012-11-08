class FeaturedReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :featured, :boolean
  end

  def self.down
    remove_column :reports, :featured
  end
end
