# run this script using: script/runner [lib\]import_events.rb
require 'fastercsv'
require 'syslog'
require 'site'
require 'calendar'
require 'event'

# we already have lat/lng, so stub geocode (which occurs after_save) 
class Event
  def geocode 
  end
end

#log = ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "../log/", File.basename(__FILE__, ".*")) + ".log")
site = Site.find_by_theme("catalogcutdown")
calendar = site.calendars.find_by_permalink("rolling")
errors = []
keys = []
event_params = {}
state_to_abbrv = {}
DemocracyInAction::Helpers.state_options_for_select(:include_provinces => true).each {|s| state_to_abbrv[s[0].downcase] = s[1]}
first_row = true
events_csv_file = File.join("#{RAILS_ROOT}", "db/Event_Report_Back_2007_11_06.csv")
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
  event.state = state_to_abbrv[event.state.downcase.strip]
  event.start += 12.hours
  event.end = event.start + 4.hours
#  event.directions ||= "unspecified"
#  event.location ||= "unspecified"
#  event.description ||= "Imported event #{event_params['id']}"
  if event_params['geo']
    origin = event_params['geo'].split(',')
    event.latitude, event.longitude = origin[0], origin[1]
  else
    geo = GeoKit::Geocoders::MultiGeocoder.geocode([event.city, event.state].join(', '))
    origin = [geo.lat, geo.lng]
    event.latitude, event.longitude = origin[0], origin[1]
    event.precision = "zip"
  end
  if event.postal_code.blank?
    if zipcode = ZipCode.find(:nearest, :select => 'zip', :origin => origin, :within => 50, :order => 'distance')
      event.postal_code = zipcode.zip
    else
      print "F(#{event_params['id']}:zip)"
      next
    end
  end
  if event.save
    print '.'
  else
    print "F(#{event_params['id']})"
    pp event
    exit
  end
  STDOUT.flush
end

