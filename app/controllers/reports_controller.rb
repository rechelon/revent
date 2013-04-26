class ReportsController < ApplicationController
  include ReportAPI

  def index
    respond_to do |format|
      format.html do
      end
      format.json do
        params[:calendar] = @calendar
        params[:published] = true
        params[:send_x_headers] = "true"
        render :json => fetch_reports(params).as_json(:include => :event)
      end
    end
  end

  def rss
    @reports = @calendar.reports.published(:all, :order => "updated_at DESC")
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end

  def list
    redirect_to :action => 'index', :permalink => @calendar.permalink
  end

 def show
    @event = @calendar.events.find(params[:event_id], :include => {:reports => :attachments, :reports => :embeds}, :order => 'reports.position')
    @pagetitle = 'Report for '+@event.name
    @liquid[:pagetitle] = @pagetitle
  end

  include ActionView::Helpers::TextHelper
  def new 
    if current_user
      @user = current_user
      @profile_complete = @user.profile_complete?
    else
      @user = User.new(params[:user])
      @profile_complete = false
    end
    redirect_to(home_url) && return if @calendar.archived?

    raise(ActionController::RoutingError.new "No route matches \"#{request.request_uri}\" with {:method=>#{request.request_method}}") if params[:id] && !(params[:id] =~ /\d+/) #this should be done in routes
    @report = Report.new(:event_id => params[:id])
    
    if params[:service] && params[:service_foreign_key]
      @report.event = Event.find_or_import_by_service_foreign_key(params[:service_foreign_key])
    end
    if @calendar.report_title_text 
      @pagetitle = @calendar.report_title_text
    else
      @pagetitle = 'Tell us what happened at your event'
    end
    @liquid[:pagetitle] = @pagetitle
    @liquid[:profile_union_form] = render_to_string :partial => 'account/profile_union_form'
  end

  def create
    redirect_to(home_url) and return unless params[:honeypot].to_s.empty? 
    reporter_data = params[:user]
    params[:report].delete :reporter_data
    @report = Report.new(params[:report].merge(:akismet_params => Report.akismet_params(request)))

    if self.current_user
      @user = self.current_user
      @user.partner_id = cookies[:partner_id] if cookies[:partner_id]
      @profile_complete = @user.profile_complete?
      @report.user = @user;
    else
      @user = User::find_or_build_related_user reporter_data, cookies
      @report.reporter_name = @user.first_name+" "+@user.last_name
      if User.find_by_email(reporter_data[:email]).blank?
        @report.user = @user;
      else
        flash[:error] = 'User with this email is registered.  Please log in first.'
        redirect_to(home_url) and return
      end
    end

    spammy = @report.spammy? real_ip
    if spammy[:result] == true
      flash[:error] = 'This report appears to be spam'
      redirect_to(home_url) and return
    elsif spammy[:result] == "unsure"
      if params[:captcha].nil?
        @liquid[:text2] = params[:report][:text2] if params[:report][:text2]
        @captcha = spammy[:captcha]
        flash.now[:error] = "Please enter the letters at the bottom of the page."
        session[:captcha_session_id] = spammy[:session_id]
        render :action => 'new'
        return
      else
        m = Mollom.new :private_key => Site.current.config.mollom_api_private_key, :public_key => Site.current.config.mollom_api_public_key
        captcha_correct = m.valid_captcha?(:session_id => session[:captcha_session_id], :solution => params[:captcha])
        session[:captcha_session_id] = nil
        unless captcha_correct
          flash[:error] = 'This report appears to be spam'
          redirect_to(home_url) and return
        end
      end
    end

    if @report.event.calendar.auto_publish_reports? || (!@report.user.nil? and @report.user.email == @report.event.host.email unless @report.event.host.nil?)
      @report.status = Report::PUBLISHED 
    end
    
=begin
    @report.make_local_copies!
    @report.build_press_links
    @report.build_embeds
=end
   
    if !@report.valid? || (!@report.user.nil? and !@report.user.valid?)
        render :action => 'new'
        return
    end
    @user.save
    @user.associate_dia_report @calendar
    @user.sync_unless_deferred
    @report.save
    @report.sync_unless_deferred

    # set redirect url
    if params[:redirect]
      @redirect_url = params[:redirect]
    elsif !@calendar.report_redirect.blank?
      @redirect_url = @calendar.report_redirect
    else
      if @report.published?
        flash[:notice] = "Thanks for reporting!"
      else
        flash[:notice] = "Thanks for reporting! Your report will be published upon review."
      end
      @redirect_url = calendar_home_url(:permalink => @calendar.permalink)      
    end
    redirect_to @redirect_url
  end

  def lightbox
    @attachment = Attachment.first(:conditions => ["attachments.parent_id = ? AND attachments.thumbnail = 'lightbox'", params[:id]], :include => :parent) || raise(ActiveRecord::RecordNotFound)
    render :layout => false
  end

  def share 
    @event = Event.find(params[:id])
    render :layout => false
  end

  def widget
    if params[:id]
      @report = Report.published.find(params[:id], :include => :attachments)
      @image = @report.attachments.first
    else
#      @image = Attachment.find(:first, :joins => 'LEFT OUTER JOIN reports ON attachments.report_id = reports.id', :conditions => ['report_id AND reports.status = ?', Report::PUBLISHED], :order => 'RAND()')
      @image = Attachment.find(:first, :include => [:report => :event], :conditions => ['report_id AND reports.status = ?', Report::PUBLISHED], :order => 'RAND()')
      @report = @image.report
    end
    render :layout => false
  end

  def featured
    if params[:id]
      @reports = @calendar.reports.featured.find(:all, :conditions => ["events.state = ?", params[:id]], :include => :event, :limit => 7, :order => 'reports.created_at DESC')
    else
      @reports = @calendar.reports.featured.find(:all, :include => :event, :limit => 7, :order => 'reports.created_at DESC')
    end
    render :layout => false
  end

  def redirect_to_show_with_permalink
    @event = Event.find(params[:event_id])
    redirect_to report_url(:host => @event.calendar.site.host, :permalink => @event.calendar.permalink, :event_id => @event.id), :status => :moved_permanently
  end
end
