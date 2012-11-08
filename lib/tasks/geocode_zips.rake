namespace :zips do
  desc "Geocode zips with missing lat, lng"
  task :geocode do
    load 'config/environment.rb'
    ZipCode.find_all_by_latitude_and_longitude(nil, nil).each do |z|
      if (geo = GeoKit::Geocoders::MultiGeocoder.geocode(z.zip)).success
        z.latitude, z.longitude = geo.lat, geo.lng
        z.save
      end 
    end
  end
end
