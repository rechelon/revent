require_dependency 'event'
require_dependency 'democracy_in_action_object'

class Workers::EventsController < WorkersController
  def index
    logger.info("running event worker******");
    @event = Event.find(params[:id])
    raise "cant find a event with id #{params[:id]}" unless @event.id

    if !@event.valid?
      raise 'invalid event: validation error'
      return false
    end 

    @event.background_processes
    render :nothing => true
  end
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
