class PrimaryReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :primary, :boolean, :default => false
  end

  def self.down
    remove_column :reports, :primary
  end
end
