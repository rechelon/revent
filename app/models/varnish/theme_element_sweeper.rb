class Varnish::ThemeElementSweeper < VarnishSweeper
  observe ThemeElement

  def after_create(element)
    hydra = Typhoeus::Hydra.new
    ban_uris = []
    purge_uris = []
    push_calendar_paths ban_uris, purge_uris, :theme_id => element.theme_id
    hydra_run_requests(hydra, bans(ban_uris) + purges(purge_uris))
    head 200
  end
  
  def after_update(element)
    hydra = Typhoeus::Hydra.new
    ban_uris = []
    purge_uris = []
    push_calendar_paths ban_uris, purge_uris, :theme_id => element.theme_id
    hydra_run_requests(hydra, bans(ban_uris) + purges(purge_uris))
    head 200
  end

  def before_destroy(element)
    hydra = Typhoeus::Hydra.new
    ban_uris = []
    purge_uris = []
    push_calendar_paths ban_uris, purge_uris, :theme_id => element.theme_id
    hydra_run_requests(hydra, bans(ban_uris) + purges(purge_uris))
    head 200
  end

  private

  def push_calendar_paths(ban_uris, purge_uris, opts)
    Calendar.find_all_by_theme_id(opts[:theme_id]).each do |c|
      ban_uris.push "#{c.permalink}/"
      purge_uris.push "#{c.permalink}"
    end
  end

end
