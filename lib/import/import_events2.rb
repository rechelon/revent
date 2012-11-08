# run this script using: script/runner [lib\]import_events.rb
require 'fastercsv'
require 'syslog'
require 'site'
require 'calendar'

# we already have lat/lng, so over-ride geocode (which occurs after_save) 
class Event
  def geocode 
  end
  def set_district
  end
end

def derive_event_zip_lat_lng(event)
  if event.postal_code.blank?
    event.precision = "city"
    zipcode = ZipCode.find_by_city_and_state(event.city, event.state)
    unless zipcode
      if geo = GeoKit::Geocoders::MultiGeocoder.geocode([event.city, event.state].join(', '))
        zipcode = ZipCode.find(:nearest, :select => 'zip', :origin => [geo.lat, geo.lng], :within => 80, :order => 'distance')
      end
    end
  else
    event.precision = "zip"
    zipcode = ZipCode.find_by_zip(event.postal_code)
  end  
  raise "ERROR: not mappable!\n #{zipcode.inspect}" unless zipcode.zip && zipcode.latitude && zipcode.longitude
  event.postal_code, event.latitude, event.longitude = zipcode.zip, zipcode.latitude, zipcode.longitude
end

#log = ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "../log/", File.basename(__FILE__, ".*")) + ".log")
site = Site.find_by_theme("catalogcutdown")
calendar = site.calendars.find_by_permalink("rolling")
errors = []
keys = []
event_params = {}
state_to_abbrv = {}
us_states = DemocracyInAction::Helpers.state_options_for_select
all_states = DemocracyInAction::Helpers.state_options_for_select(:include_provinces => true)
provinces = all_states - us_states
first_row = true
events_csv_file = File.join("#{RAILS_ROOT}", "db/fall07actionsforREVENT.csv")
count = 0
FasterCSV.foreach(events_csv_file) do |row|
  if first_row
    keys = row.dup
    first_row = false
    next
  end
  0.upto(keys.length) {|i| event_params[keys[i]] = row[i]}
  if event_params['email']
    host = User.find_or_initialize_by_site_id_and_email(site.id, event_params['email'])
    host.first_name = event_params['first_name']
    host.last_name = event_params['last_name']
    host.phone = event_params['phone']
    unless host.crypted_password
      password = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      host.password = host.password_confirmation = password
    end
  else
    host = User.find_or_initialize_by_site_id_and_email(site.id, 'shana@forestethics.org')
    host.first_name ||= 'Shana'
    host.last_name ||= 'Ortman'
  end
  unless host.save
    print "F(#{event_params['id']}:host)"
    next
  end
  filter_params = %w(name description location postal_code state city start end)
  build_params = event_params.reject {|k,v| not filter_params.include?(k)}
  event = calendar.events.build(build_params)
  event.host_id = host.id if host && host.id
  event.country_code = Event::COUNTRY_CODE_CANADA if provinces.include?(event.state)
  event.start += 12.hours
  event.end = event.start + 4.hours
  event.description ||= event.name
  event.location ||= "unspecified"
  derive_event_zip_lat_lng(event)
  
  if event.save
    count += 1
    puts "#{count}"
#    print '.'
  else
    print "F(#{event_params['id']})"
    pp event
    exit
  end
  STDOUT.flush
end
