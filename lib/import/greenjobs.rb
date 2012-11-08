class Event < ActiveRecord::Base
  def sync_to_democracy_in_action
  end
  def geocode
  end
end

class User < ActiveRecord::Base
  def sync_to_democracy_in_action
  end
end

class DemocracyInAction::API
  def delete
    raise 'deleting'
  end
  def process
    raise 'processing'
  end
end

module Import
  class Greenjobs
    
    def self.run
      Object.const_set(:DIA_ENABLED, true)

      Site.current = Site.find 19
      calendar = Site.current.calendars.find_by_permalink("recoveryactions")
      DemocracyInActionEvent.find(:all, :conditions => 'distributed_event_KEY=51').each do |dia_event|
        create_from_democracy_in_action_event(calendar, dia_event)
      end
    ensure
      Object.const_set(:DIA_ENABLED, false)
    end

    def self.create_from_democracy_in_action_event(calendar, dia_event)
      e = calendar.events.build
      e.name = dia_event.Event_Name
      e.location = dia_event.Address
      e.directions = dia_event.Directions
      e.city = dia_event.City
      e.state = dia_event.State
      if dia_event.City.nil? or dia_event.State.nil?
        if dia_event.Zip
          z = ZipCode.find_by_zip(dia_event.Zip)
          e.city, e.state = z.city, z.state if z
        end
      end
      e.postal_code = dia_event.Zip
      e.latitude = dia_event.Latitude 
      e.longitude = dia_event.Longitude
      e.description = dia_event.Description
      e.start = dia_event.Start 
      e.start ||= calendar.event_start #'4/1/08'.to_time.beginning_of_day + 12.hours
      e.end = e.start + 2.hours 
      
      puts "creating event: #{e.name}"
      
      supporter = DemocracyInActionSupporter.find(dia_event.supporter_KEY)
      raise 'no supporter' unless supporter
      host = User.create_from_democracy_in_action_supporter(calendar.site, supporter)

      puts "  creating host: #{host.email}"
      
      e.host_id = host.id
      dia_obj = DemocracyInActionObject.new(:table => 'event', :key => dia_event.event_KEY) 
      dia_obj.save
      unless e.save
        RAILS_DEFAULT_LOGGER.warn("Validation error(s) occurred when trying to create event from DemocracyInActionEvent: #{e.errors.inspect}")
        e.save_with_validation(false)
      end
      dia_obj.synced = e
      dia_obj.save
      dia_event.attendees.each do |attendee|
        u = User.create_from_democracy_in_action_supporter(calendar.site, DemocracyInActionSupporter.find(attendee.supporter_KEY))

        puts "  creating attendee: #{u.email}"
        
        rsvp = e.rsvps.create(:user_id => u.id)
      end
    end
  end
end
