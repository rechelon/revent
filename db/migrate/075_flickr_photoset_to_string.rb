class FlickrPhotosetToString < ActiveRecord::Migration
  def self.up
    Calendar.find(:all).each {|c| }
    change_column :calendars, :flickr_photoset, :string
  end
  def self.down
    change_column :calendars, :flickr_photoset, :integer
  end
end