class AddText3AndText4ToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :text3, :text
    add_column :reports, :text4, :text
  end

  def self.down
    remove_column :reports, :text4
    remove_column :reports, :text3
  end
end
