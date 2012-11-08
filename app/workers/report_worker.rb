require_dependency 'user'
require_dependency 'democracy_in_action_object'
require_dependency 'press_link'

class ReportWorker < Struct.new(:report_id)
  def perform
    raise "cant find a report with id #{report_id}" unless report.id
    if !report.event 
      raise 'invalid report: report has no event'
      return false
    end 
    Site.current = report.event.calendar.site
    Host.current = report.event.calendar.site.host
    if !report.valid?
      raise 'invalid report: validation error'
      return false
    end 
    

    ActionController::Base.page_cache_directory = File.join([RAILS_ROOT, (RAILS_ENV == 'test' ? 'tmp' : 'public'), 'cache', Host.current.hostname]) #aka, set_cache_root
    report.background_processes
    report.trigger_email
    
  end

  def logger
    RAILS_DEFAULT_LOGGER
  end
  def report
    @report ||= Report.find( report_id )
  end
end
