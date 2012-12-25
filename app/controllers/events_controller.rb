class EventsController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper

  before_filter :disable_create, :only => [:new, :create, :rsvp]

  verify :method => :post, :only => [:create, :rsvp], :redirect_to => {:action => 'index'}

  caches_page_unless_flash :total, :show, :international
  caches_action :index
  cache_sweeper :event_sweeper, :only => :create
  
  def disable_create
    redirect_to(home_url) && return if @calendar.archived?
    if params[:id]
      @event = @calendar.events.find(params[:id]) 
      redirect_to home_url if @event.past?
    else
      redirect_to home_url if @calendar.past?
    end
  end
  
  def category
    @category_options = @calendar.categories.collect{|c| [c.name, c.id]}.unshift(['All Events', 'all'])
    if params[:id] and not params[:id] == 'all'
      @category = @calendar.categories.find(params[:id])  
      @events = @calendar.events.searchable.paginate_all_by_category_id(@category.id, :order => 'created_at DESC', :page => params[:page])
    else
      require 'ostruct'
      @category = OpenStruct.new(:id => 'all', :name => 'All Events')
      @events = @calendar.events.searchable.paginate(:order => 'created_at DESC', :page => params[:page])
    end
  end
  
  def recently_updated
    respond_to do |format|
      format.html do 
        @events = @calendar.events.searchable.paginate(:order => 'updated_at DESC', :page => params[:page])
      end
      format.xml do 
        @events = @calendar.events.searchable.find(:all, :order => 'updated_at DESC', :limit => 4)
        render :action => 'recently_updated.rxml', :layout => false
      end
    end
  end

  def recently_added 
    respond_to do |format|
      format.html do 
        @events = @calendar.events.searchable.paginate(:order => 'created_at DESC', :page => params[:page])
      end
      format.xml do 
        @events = @calendar.events.searchable.find(:all, :order => 'created_at DESC', :limit => 4)
        render :action => 'recently_added.rxml', :layout => false
      end
    end
  end

  def upcoming
    respond_to do |format|
      format.html do 
        if params['worksite'] 
          @events = @calendar.events.worksite.upcoming.paginate(:page => params[:page])
        else
          @events = @calendar.events.searchable.upcoming.paginate(:page => params[:page])
        end
        render :action => 'upcoming.rhtml'
      end
      format.xml do 
        @events = @calendar.events.searchable.upcoming.find(:all, :limit => Site.current.config.calendar_list_upcoming_events_xml_limit)
        render :action => 'upcoming.rxml', :layout => false 
      end
    end
  end
  
  def upcoming_rss
    respond_to do |format|
      format.xml do
        @events = @calendar.events.searchable.upcoming.find(:all, :limit => Site.current.config.calendar_list_upcoming_events_xml_limit)
        @feed_title = 'Upcoming Events'
        @feed_url = "http://" + request.host_with_port + request.request_uri
        @feed_description = 'Upcoming events for ' + Site.current.host.hostname
        render :action => 'rss.rxml', :layout => false
      end
    end
  end
  
  def past_rss
    respond_to do |format|
      format.xml do
        @events = @calendar.events.searchable.past.find(:all)
        @feed_title = 'Past Events'
        @feed_url = "http://" + request.host_with_port + request.request_uri
        @feed_description = 'Past events for ' + Site.current.host.hostname
        render :action => 'rss.rxml', :layout => false
      end
    end
  end 
  
  def rss
    respond_to do |format|
      format.xml do
        @events = @calendar.events.searchable.find(:all)
        @feed_title = 'Events'
        @feed_url = "http://" + request.host_with_port + request.request_uri
        @feed_description = 'Events for ' + Site.current.host.hostname
        render :action => 'rss.rxml', :layout => false
      end
    end
  end 
  
  def past 
    respond_to do |format|
      format.html do 
        if params['worksite'] 
          @events = @calendar.events.worksite.past.paginate(:page => params[:page])
        else
          @events = @calendar.events.searchable.past.paginate(:page => params[:page])
        end
      end
      format.xml do 
        @events = @calendar.events.searchable.past
        render :action => 'upcoming.rxml', :layout => false
      end
    end
#    cache_page nil, :permalink => params[:permalink]
  end

  def total
    @states = @calendar.events.find(:all).collect {|e| e.state}.compact.uniq.select do |state|
      STATE_CENTERS.keys.reject {|c| :DC == c}.map{|c| c.to_s}.include?(state)
    end
    @event_count = @calendar.events.count
    respond_to do |format|
      format.js { headers["Content-Type"] = "text/javascript; charset=utf-8" }
      format.html { render :layout => false }
    end
  end

  def show
    @event = @calendar.events.find(params[:id], :include => [:blogs, :custom_attributes, {:reports => :attachments}])
    @event_custom_attributes = @event.custom_attributes_data
    @pagetitle = @event.name 
    @liquid[:pagetitle] = @pagetitle
    if @calendar.map_engine == "osm"
      @osm_key = Host.current.cloudmade_api_key;
    end
    @icons = {
      :icon_upcoming => @calendar.icon_upcoming || Site.current.config.icon_upcoming,
      :icon_past => @calendar.icon_past || Site.current.config.icon_past,
      :icon_worksite => @calendar.icon_worksite || Site.current.config.icon_worksite
    }
  end

  def copy
    if params[:id].blank?
      render(:text => 'Could not find event to copy')
      return
    end
    @old_event = Event.find(params[:id], :include => :custom_attributes)
    if @old_event.nil?
      render(:text => 'Could not find event to copy')
      return
    end
    @event = Event.new @old_event.attributes
    @old_event.custom_attributes.each do |a|
      @event.custom_attributes.build a.attributes
    end
    @redirect_url = manage_account_url :permalink => @calendar.permalink
    new
  end
  
  def new
    if !session[:event_data].nil?
      @event = Event.new(Marshal.load(session[:event_data]))
      session[:event_data] = nil
    else
      @event = Event.new params[:event] if @event.nil?
    end
    if current_user
      @user = current_user
      @profile_complete = @user.profile_complete?
    else
      @user = User.new(params[:user])
      @profile_complete = false
    end
    @hostform = @calendar.hostform
    @categories = @calendar.categories.map {|c| [c.name, c.id] }
    @user_custom_attributes = @user.custom_attributes_data
    @event_custom_attributes = @event.custom_attributes_data

    @event_start_date = @event.start ? @event.start.strftime('%m/%d/%Y') : ''
    @event_start_time = @event.start ? @event.start.strftime('%I:%M %p') : ''
    @event_end_date = @event.end ? @event.end.strftime('%m/%d/%Y') : ''
    @event_end_time = @event.end ? @event.end.strftime('%I:%M %p') : ''            
    
    #if current_theme
      #cookies[:partner_id] = {:value => params[:partner_id], :expires => 3.hours.from_now} if params[:partner_id] 
      #return if render_partner_signup_form
    #end

    @liquid[:union_form] = render_to_string :partial => '/events/union_form'
    unless Site.current.config.custom_event_options['targets_official'].nil?
      @liquid[:elected_official_form] = render_to_string :partial => '/events/elected_official_form'
    end
    @liquid[:nonviolent_form] = render_to_string :partial => '/events/nonviolent_form'
    @liquid[:profile_union_form] = render_to_string :partial => 'account/profile_union_form'
    render :action=>'new'
  end

  def js_new
    @event = Event.new params[:event]
    @user = current_user ||  User.new(params[:user])
    @categories = @calendar.categories.map {|c| [c.name, c.id] }
    #if current_theme
      #cookies[:partner_id] = {:value => params[:partner_id], :expires => 3.hours.from_now} if params[:partner_id] 
      #return if render_partner_signup_form
    #end
    render :action=>'js_new', :layout=>false
  end
  
  def thankyou 
    @event = @calendar.events.find(params[:id], :include => [:blogs, :custom_attributes, {:reports => :attachments}])
    @pagetitle = @event.name 
    @liquid[:pagetitle] = @pagetitle
    if @calendar.map_engine == "osm"
      @osm_key = Host.current.cloudmade_api_key;
    end

  end

  def create
    # build new event
    @event = @calendar.events.build(params[:event])

    # set start and end if form uses seperate date and time fields
    if(!params['event_start_date'].blank?)
      @event.set_start_from_date_and_time(params['event_start_date'],params['event_start_time'])
    end
    
    if(!params['event_end_date'].blank?)
      @event.set_end_from_date_and_time(params['event_end_date'],params['event_end_time'])
    end

    if params[:event_privacy_level]
      case params[:event_privacy_level]
        when 'worksite' 
          @event.worksite_event = true
          @event.private = false 
        when 'private' 
          @event.private = true
          @event.worksite_event = false 
        else
          @event.private = false
          @event.worksite_event = false 
        end
    end

    # build new user
    if self.current_user
      @user = self.current_user
      @user.partner_id  = cookies[:partner_id] if cookies[:partner_id]
    else
      @user = User::find_or_build_related_user params[:user], cookies
      if !User.find_by_email(@user.email).blank?
        flash[:error] = 'User with this email already exists.  Please <a href="'+url_for(:action => 'new')+'" class="flash-login-btn" >log in</a> and try again.'
        @event.clean_date_time
        if params[:event] # we won't have params[:event] if @calendar.events is stubbed out!
          session[:event_data] = Marshal.dump(params[:event].merge(:start => @event.start, :end => @event.end))
        end
        @categories = @calendar.categories.map {|c| [c.name, c.id] }
        render :action => 'new'
        return
      end
    end

    # validate both user and event
    if @user.valid? and @event.valid?

      # create profile image and save user
      @user.create_profile_image(params[:profile_image]) unless !params[:profile_image] || !params[:profile_image][:uploaded_data] || params[:profile_image][:uploaded_data].blank?
      @user.save!
      @user.associate_dia_host @calendar
      @user.sync_unless_deferred

      #set user as host
      @event.host = @user
      
      # save event
      @event.time_tbd = params[:tbd] if params[:tbd]
      @event.host_alias = true unless params[:event_host]
      @event.save!
      @event.associate_dia_event @calendar.hostform
      @event.sync_unless_deferred

      # set redirect url
      if params[:redirect]
        flash[:notice] = 'Your event was successfully created.'
        @redirect_url = params[:redirect]
      elsif @calendar.signup_redirect
        flash[:notice] = 'Your event was successfully created.'
        @redirect_url = @calendar.signup_redirect
      elsif Site.current.config.event_thank_you_page
        flash[:notice] = 'Your event was successfully created.'
        @redirect_url = "/#{@calendar.permalink}/events/thankyou/#{@event.id}"
      else
        flash[:notice] = 'Your event was successfully created.'
        @redirect_url = "/#{@calendar.permalink}/events/show/#{@event.id}"
      end

      # if ajax form, do ajax redirect 
      if params[:ajax]
        render :action => 'redirect_to_event', :layout => false
        return
      end

      # otherwise, do full-page redirect
      redirect_to @redirect_url
      return

    # if invalid, redraw event form
    else
      flash.now[:error] = 'There was a problem creating your event - please double check your information and try again.'
      @categories = @calendar.categories.map {|c| [c.name, c.id] }

      if(params[:ajax])
        render :action => 'js_new', :layout => false
      else
        new
      end

    end
  end


  def rsvp
    @event = @calendar.events.find(params[:id])
    if !@event.worksite_event?
      if self.current_user
        @user = self.current_user
      else
        @user = User.find_or_initialize_by_email(params[:user][:email]) 
      end
      @user.fill_in_blank_attributes params[:user]
      @user.partner_id  = cookies[:partner_id] if cookies[:partner_id]

      if(@user.id && (@rsvp = Rsvp.find_by_event_id_and_user_id(@event.id,@user.id)))
          flash.now[:error] = "Looks like you have already RSVP'd to this event."
          return
      else
        @rsvp = Rsvp.new(:event_id => params[:id])
      end
      if @user.valid? and @rsvp.valid?
        assign_democracy_in_action_tracking_code( @user, cookies[:partner_id] ) if cookies[:partner_id]
        @user.save
        @user.associate_dia_rsvp @event, @calendar
        @user.sync_unless_deferred
        @rsvp.user_id = @user.id
        @rsvp.save
        if params[:redirect]
          redirect_to params[:redirect]
        elsif !@calendar.rsvp_redirect.blank?
          redirect_to @calendar.rsvp_redirect
        else      
          flash.now[:notice] = "<b>Thanks for the RSVP!</b><br /> An email confirming your RSVP has been sent to the email address you provided."
          show  # don't call show on same line as render
          render(:action => 'show', :id => @event)
        end
      else
        flash.now[:notice] = 'There was a problem registering your RSVP.'       
        show  # don't call show on same line as render
        render(:action => 'show', :id => @event)
      end
    else
      flash.now[:notice] = 'You cannot RSVP for worksite events.'
      render(:action => 'show', :id => @event)
    end
  end

  def fb_rsvp
    #decode fb response
    sig, fb_data = params['signed_request'].split('.',2)
    fb_data += '=' * (4 - fb_data.length.modulo(4))
    fb_user = JSON.parse(Base64.decode64 fb_data.tr('-_','+/'))
    @event = @calendar.events.find(params[:id])

    # login and return if user already exists
    if @user = User.find_by_email_and_site_id(fb_user['registration']['email'], Site.current.id)
      @user.fb_id = fb_user['user_id'] unless @user.fb_id
    else
    # otherwise create new user    
      fb_user['first_name'], fb_user['last_name'] = fb_user['registration']['name'].split(' ',2)
      @user = User.new :first_name => fb_user['first_name'],
                       :last_name => fb_user['last_name'],
                       :email => fb_user['registration']['email']
      @user.fb_id = fb_user['user_id'] unless @user.fb_id
      @user.set_site_id
      @user.assign_password
      @user.admin = false
      @user.activate_new_user
    end

    @rsvp = Rsvp.new(:event_id => params[:id]) 
    
    if @user.valid? && @rsvp.valid?
      @user.save
      @user.sync_unless_deferred
      cookies[:revent_auth] = '1';
      self.current_user = @user
      assign_democracy_in_action_tracking_code( @user, cookies[:partner_id] ) if cookies[:partner_id]
      @user.save
      @user.sync_unless_deferred
      @rsvp.user_id = @user.id
      @rsvp.save
      
      if !@calendar.rsvp_redirect.blank?
        redirect_to @calendar.rsvp_redirect
      else      
        flash[:notice] = "<b>Thanks for the RSVP!</b><br /> An email confirming your RSVP has been sent to the email address you provided."
        redirect_to manage_account_url(:permalink=>@calendar.permalink)
      end
    else
      flash.now[:notice] = 'There was a problem registering your RSVP.'       
      render(:action => 'show', :id => @event)
    end
  end
  
  def reports
    if params[:id]
      @event = @calendar.events.find(params[:id], :include => :reports)
    else
      redirect_to :controller => :reports, :action => :index
    end
  end

  def other_state_events
    state = params[:event_state]
    unless state.blank?
      @other_state_events = @calendar.events.searchable.find_all_by_state(state)
      unless @other_state_events.empty?
        render(:partial => 'other_state_events', :layout => false) && return
      end
    end
    render :nothing => true    
  end

  def nearby_events
    postal_code = params[:postal_code]
    unless postal_code.blank?
      begin
        @nearby_events = @calendar.events.upcoming.searchable.find(:all, :origin => postal_code, :within => 25)
      rescue GeoKit::Geocoders::GeocodeError
        render(:text => "", :layout => false) and return
      end
      unless @nearby_events.empty?
        render(:partial => 'shared/nearby_events', :layout => false) && return
      end
    end
    render :nothing => true
  end

  def host
    @event = @calendar.events.find(params[:id], :include => :host)
    @host = @event.host
    @pagetitle = 'Profile for '+@event.host_public_full_name
    @liquid[:pagetitle] = @pagetitle
  end

  def email_host
    @event = @calendar.events.find(params[:id], :include => :host)
    @host = @event.host
    @post_url = File.join( '',@calendar.permalink,'events','email_host',@event.to_param )
    return render(:action=> 'email_host', :layout=>false) if params[:ajax] 
    
    if request.post?
      # if the hidden first_name field is set, it is likely bot request, so ignore
      return render(:action => 'show', :id => @event) unless params[:first_name].blank?
      if params[:from_email] && params[:from_email ] =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

        message = {
          :from => "\"#{params[:from_name]}\" <#{params[:from_email]}>", 
          :subject => params[:subject], 
          :body => params[:body] }
        if @event.democracy_in_action_key.blank? || !Site.current.config.salsa_enabled?
          UserMailer.deliver_message_to_email(message, @event.host_public_email)
        else
          message[:to] = @event.host_public_email
          message[:from] = params[:from_email]
          message[:content] = message[:body]
          DemocracyInActionResource.api.authenticate
          DemocracyInActionResource.api.email message
        end
        flash[:notice] = "Message sent."
        redirect_to( :controller => 'events', :permalink => @calendar.permalink, :action => 'show', :id => @event )        
      else
        flash.now[:error] = "You must specify your email."
      end
    end
  end

  # params['conditions'] and params['sort'] are ActiveRecord query hash
  def index
    redirect_to calendar_home_url(:permalink=>@calendar.permalink) and return unless params[:query] || params[:sort]

    origin = params[:query].delete(:origin) || params[:query].delete(:zip) if params[:query]
    options = origin ? {:origin => origin, :within => 50, :order => 'distance'} : {}
    options.merge!(:page => params[:page] || 1, :per_page => params[:per_page] || Event.per_page)
    @events = @calendar.events.prioritize(params[:sort]).searchable.by_query(params[:query]).paginate(options)
    respond_to do |format|
      format.xml { render :xml => @events }
      format.json { 
        if params[:callback] && params[:target]
          render :json => "Event.observe( window, 'load', function() { #{params[:callback]}(#{@events.to_json( :methods => [ :start_date, :segmented_date ] )}, '#{params[:target]}'); });"
        elsif params[:callback]
          render :json => @events.to_json( :methods => [ :start_date, :segmented_date ] ), :callback => params[:callback]
        else
          render :json => @events
        end
      }
    end
  end

  def international
    @country_a3 = params[:id] || 'all'
    @country_code = CountryCodes.find_by_a3(@country_a3.upcase)[:numeric] || 'all'
    if @country_code == 'all'
      @events = @calendar.events.searchable.paginate(:conditions => ["country_code <> ?", Event::COUNTRY_CODE_USA], :order => 'country_code, city, start', :page => params[:page])
    else
      @events = @calendar.events.searchable.paginate(:conditions => ["country_code = ?", @country_code], :order => 'start, city', :page => params[:page])
    end
  end
 
  def description
    @event = @calendar.events.find(params[:id])
    render :update do |page|
      page.replace_html 'report_event_description', "<h3>Event Description</h3>#{@event.description}"
      page.show 'report_event_description'
    end
  end

  protected

    #def render_partner_signup_form
      #if cookies[:partner_id] && is_partner_form(cookies[:partner_id])
        #render :template => "events/partners/#{cookies[:partner_id]}/new"
      #end
    #end
  
    def assign_democracy_in_action_tracking_code( user, code )
      return unless code
      user.democracy_in_action ||= {}
      if @calendar.id == 8 # momsrising.fair-pay  #credit: seth walker
        user.democracy_in_action['supporter_custom'] ||= {}
        user.democracy_in_action['supporter_custom']['VARCHAR3'] = code
      else
        user.democracy_in_action['supporter'] ||= {}
        user.democracy_in_action['supporter']['Tracking_Code'] = "#{code}_rsvp"
      end
    end

    #hmm, why is this here? oh yes, for objects retrieved from memcache?
    def autoload_missing_constants
      yield
#    rescue ArgumentError, MemCache::MemCacheError => error
    rescue ArgumentError
      lazy_load ||= Hash.new { |hash, key| hash[key] = true; false }
      retry if error.to_s.include?('undefined class') && 
        !lazy_load[error.to_s.split.last.constantize]
      raise error
    end  

  private
    #def is_partner_form(form)
      #File.exist?("themes/#{current_theme}/views/events/partners/#{form}")
    #end
end
