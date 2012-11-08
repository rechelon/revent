class AddSiteIdAndPermalinkSlugToCalendars < ActiveRecord::Migration
  def self.up
    add_column :calendars, :permalink, :string
    add_index :calendars, :permalink

    add_column :calendars, :site_id, :integer 
  end

  def self.down
    remove_column :calendars, :permalink
    remove_column :calendars, :site_id
  end
end
