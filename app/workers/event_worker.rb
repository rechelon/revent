require_dependency 'event'
require_dependency 'democracy_in_action_object'

class EventWorker < Struct.new(:event_id)
  def perform
    logger.info("running delayed Job******")
    raise "cant find a event with id #{event_id}" unless event.id

    Site.current = event.calendar.site
    Host.current = event.calendar.site.host

    if !event.valid?
      raise 'invalid event: validation error'
      return false
    end 

    event.background_processes
  end 
 
  def event
    @event ||= Event.find(event_id, :include=>:calendar)
  end
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
