class EmbedsAndAttendeesForReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :embed, :text
    add_column :reports, :attendees, :integer
  end

  def self.down
    remove_column :reports, :embed
    remove_column :reports, :attendees
  end
end
