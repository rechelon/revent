class Varnish::EventSweeper < VarnishSweeper
  observe Event

  def after_create(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_event_calendar_paths uris, {:permalink => event.calendar.permalink, :event_id => event.id}
    hydra_run_requests(hydra, purges(uris))
    head 200
  end
  
  def after_update(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_event_calendar_paths uris, {:permalink => event.calendar.permalink, :event_id => event.id}
    hydra_run_requests(hydra, purges(uris))
    head 200
  end

  def before_destroy(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_event_calendar_paths uris, {:permalink => event.calendar.permalink, :event_id => event.id}
    hydra_run_requests(hydra, purges(uris))
    head 200
  end

  private

  def push_event_calendar_paths(uris, opts)
    if parent_calendar = Calendar.find_by_permalink(opts[:permalink]).parent
      uris.push "#{parent_calendar.permalink}/maps"
      uris.push "#{parent_calendar.permalink}/events/show/#{opts[:event_id]}"
    end
    uris.push "#{opts[:permalink]}/maps"
    uris.push "#{opts[:permalink]}/events/show/#{opts[:event_id]}"
  end

end
