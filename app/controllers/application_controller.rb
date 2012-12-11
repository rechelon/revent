# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter  :clean, :set_site, :set_calendar, :provide_liquid, :log_forwarded_ip
  helper_method  :site 
  
  rescue_from ActionController::UnknownAction, :with => :unknown    

#  include HoptoadNotifier::Catcher
#  session :off, :if => Proc.new { |req| !(true == req.parameters[:admin]) }
  
  def clean
    Site.current = nil
    true
  end

  def site
    Site.current
  end

  def set_site
    Calendar #need this for instantiating from memcache, could also override autoload_missing_constants like we do in events_controller
    Site.current = cache("site_for_host_#{request.host}") { Site.find_by_host(request.host) } 
    Host.current = cache("host_#{request.host}") { Host.find_by_hostname(request.host) } 
    raise 'no site' unless site
  end

  def set_calendar
    @calendar = site.calendars.detect {|c| params[:permalink] == c.permalink } || site.calendars.detect {|c| c.current?} || site.calendars.last    
    raise 'no calendar' unless @calendar
  end

  def provide_liquid
    @liquid ||= {}
    @liquid[:flash] = render_to_string :partial=>'/shared/flash', :locals=>{:flash => flash}
    @liquid[:take_action] = render_to_string :partial=>'/shared/take_action'
    @liquid[:manage] = render_to_string :partial=>'/shared/manage'
    @liquid[:event_spotlight] = render_to_string :partial=>'events/event_spotlight'
    @liquid[:fb_load] = render_to_string :partial=>'/shared/fb_load'
    @liquid[:permalink] = @calendar.permalink
    @liquid[:host] = request.host
    @liquid[:site_name] = @calendar.theme.site_name
    @liquid[:site_description] = @calendar.theme.site_description
    @liquid[:url] = request.url
  end

  def log_forwarded_ip
    unless VARNISH_SERVERS.empty?
      RAILS_DEFAULT_LOGGER.info("X-Forwarded-For: "+request.env['HTTP_X_FORWARDED_FOR'].to_s)
    end
  end

  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    path = "#{RAILS_ROOT}/public/#{status[0,3]}.html"
    if File.exist?(path)
      render :file => path, :status => status
    else
      head status
    end
  end

  def self.caches_page_unless_flash(*args)
    return unless perform_caching
    actions = args.map(&:to_s)
    after_filter { |c| c.cache_page if actions.include?(c.action_name) && c.send(:flash)[:error].blank? && c.send(:flash)[:notice].blank? }
  end

  private

  def unknown
    case action_name
    when /;/
      render_optional_error_file(404) && return
    end

    case request.path
    when /\.php$/
      render_optional_error_file(404) && return
    end

    raise
  end
end
