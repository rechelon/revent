class Event
  def geocode
  end
end

class LatlngPrecision < ActiveRecord::Migration
  def self.up
    add_column :events, :precision, :string
    Event.find(:all).each do |e|
      if e.latitude and e.longitude
        e.precision = "address"
      elsif e.fallback_latitude and e.fallback_longitude
        e.latitude, e.longitude = e.fallback_latitude, e.fallback_longitude
        e.precision = "zip"
      elsif e.postal_code =~ /^\d{5}(-\d{4})?$/ and (zip = ZipCode.find_by_zip(e.postal_code))
        e.latitude, e.longitude = zip.latitude, zip.longitude
        e.precision = "zip"
      elsif e.postal_code # geocode US zip codes not in ZipCode table and Canadian postal codes
        if (geo = GeoKit::Geocoders::MultiGeocoder.geocode(e.postal_code)).success
          e.latitude, e.longitude = geo.lat, geo.lng
          e.precision = geo.precision
        end
      end
      print (e.save ? '.' : "F(#{e.id})")
      STDOUT.flush
    end
=begin  
    remove_column :events, :fallback_latitude
    remove_column :events, :fallback_longitude
=end
  end
  
  def self.down
    remove_column :events, :precision
=begin
    add_column :events, :fallback_latitude, :float
    add_column :events, :fallback_longitude, :float
=end
  end
end
