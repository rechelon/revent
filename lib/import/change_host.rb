RAILS_ENV = 'production'
require File.dirname(__FILE__) + '/../../config/environment'

require 'fastercsv'
require 'syslog'
require 'site'
require 'calendar'
require 'user'

# we already have lat/lng, so over-ride geocode (which occurs after_save) 
class Event
  def geocode 
  end
  def set_district
  end
  def sync_to_democracy_in_action
  end
  def trigger_email
  end
end

class User
  def sync_to_democracy_in_action
  end
end

#log = ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "../log/", File.basename(__FILE__, ".*")) + ".log")
Site.current = Site.find_by_theme("catalogcutdown")
calendar = Site.current.calendars.find_by_permalink("rattlingcages")
keys = []
event_params = {}
first_row = true
events_csv_file = File.join("#{RAILS_ROOT}", "db/imports/rattlingcages_calendar.csv")
count = 0
FasterCSV.foreach(events_csv_file) do |row|
  if first_row
    keys = row.dup
    first_row = false
    next
  end
  0.upto(keys.length) {|i| event_params[keys[i]] = row[i]}
  if event_params['id']
    event = Event.find(event_params['id'])
    host = User.find_or_initialize_by_site_id_and_email(Site.current.id, event_params['email'])
    host.first_name = event_params['first_name']
    host.last_name = event_params['last_name']
    host.phone = event_params['phone']
    unless host.crypted_password
      password = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      host.password = host.password_confirmation = password
    end
    unless host.save
      print "F(#{event_params['id']}:host)"
      next
    end
    event.host_id = host.id if host && host.id
    if event.save
      api = DemocracyInAction::API.new(DemocracyInAction::Config.new(File.join(Site.current_config_path, 'democracyinaction-config.yml')))
      api.process('supporter_groups', {"supporter_KEY" => host.democracy_in_action_key, "groups_KEY" => 60676})
      print '.'
    else
      print "F(#{event_params['id']})"
      pp event
      exit
    end
    STDOUT.flush
  end
end
