require_dependency 'user'
require_dependency 'democracy_in_action_object'
require_dependency 'press_link'

class Workers::ReportsController < WorkersController
  def index
    @report = Report.find(params[:id])
    raise "cant find a report with id #{params[:id]}" unless @report.id

    @report.embed_data = params[:embed_data]
    @report.press_link_data = params[:press_link_data]

    if !@report.event 
      raise 'invalid report: report has no event'
      return false
    end 

    if !@report.valid?
      raise 'invalid report: validation error'
      return false
    end 

    ActionController::Base.page_cache_directory = Rails.root.join((Rails.env.test? ? 'tmp' : 'public'), 'cache', Host.current.hostname) #aka, set_cache_root
    @report.background_processes
    @report.trigger_email
    render :nothing => true
  end

  def logger
    Rails.logger
  end
end
