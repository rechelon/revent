class AddFlickrTagToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :flickr_tag, :string
    add_column :calendars, :flickr_additional_tags, :string
    add_column :calendars, :flickr_photoset, :integer
  end
  
  def self.down
    remove_column :calendars, :flickr_tag
    remove_column :calendars, :flickr_additional_tags
    remove_column :calendars, :flickr_photoset
  end
end