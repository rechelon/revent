class Varnish::EventSweeper < VarnishSweeper
  observe Event

  def after_create(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_ajax_paths uris, :permalink => event.calendar.permalink
    hydra_run_requests(hydra, purges(uris))
    head 200
  end
  
  def after_update(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_ajax_paths uris, :permalink => event.calendar.permalink
    uris.push "#{event.calendar.permalink}/events/show/#{event.id}"
    hydra_run_requests(hydra, purges(uris))
    head 200
  end

  def before_destroy(event)
    hydra = Typhoeus::Hydra.new
    uris = []
    push_ajax_paths uris, :permalink => event.calendar.permalink
    uris.push "#{event.calendar.permalink}/events/show/#{event.id}"
    hydra_run_requests(hydra, purges(uris))
    head 200
  end

  private

  def push_ajax_paths(uris, opts)
    if parent_calendar = Calendar.find_by_permalink(opts[:permalink]).parent
      uris.push "#{parent_calendar.permalink}/maps"
    end
    uris.push "#{opts[:permalink]}/maps"
  end

end
