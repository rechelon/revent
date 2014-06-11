class AdminController < ApplicationController
  before_filter :login_required, :except => ['login', 'reset_password']
  include EventImport

  def login
    if request.post?
      self.current_user = User.authenticate(params[:email], params[:password])
      if current_user
        if params[:remember_me] == "1" && current_user.respond_to?(:remember_me)
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default(:controller => 'admin', :action => 'index')
      else
        flash[:notice] = "Login failed"
        render :layout => 'admin_login'
      end
      return
    else
      response.etag = nil
      response.headers["Pragma"] = "no-cache"
      response.headers["Cache-Control"] = "no-cache"
      render :layout => 'admin_login'
    end
  end
  
  def reset_password
    response.etag = nil
    response.headers["Pragma"] = "no-cache"
    response.headers["Cache-Control"] = "no-cache"
    render :layout => 'admin_login'
  end

  def index
    @calendars = Calendar.find(:all,{:conditions=>{:site_id=>Site.current.id},:include=>[:hostform,:triggers,:categories]})
    if !current_user.site_admin?
      @sponsors = Sponsor.find(:all,{:conditions=>{:site_id=>Site.current.id,:id=>current_user.user_permissions_data[:sponsor_admin]},:include=>[:admins]})
    else
      @sponsors = Sponsor.find(:all,{:conditions=>{:site_id=>Site.current.id},:include=>[:admins]})
    end
    @themes = Theme.find(:all,{:conditions=>{:site_id=>Site.current.id}})
    @site_id = Site.current.id
  end

  def import
    require 'fastercsv'
    calendar = Calendar.find params[:calendar_id]
    unless params[:category_id].blank?
      category = Category.find params[:category_id]
    end
    file = params[:"event-import"].path
    events = []
    users = []
    @errors = []
    @dupes = []
    @headers = params[:headers]
    @lineno = 0; 
    FasterCSV.foreach(file, {:headers => @headers, :col_sep => "\t"} ) do |row|
      @lineno += 1

      #skip the headers
      if(@lineno == 1)
        next
      end
      
      #skip rows where all values are nil, this happens due to a newline at the end of the file
      if(row.to_hash.values.select{|n| n != nil}.empty?)
        next
      end

      id_field = row[ID_FIELD] || 'no id'
      if row[START_DATE_FIELD].blank?
        @errors << "No start date for event with id: " + id_field
      end

      start_date = row[START_DATE_FIELD]

      if row[START_TIME_FIELD].blank?
        start_time = '8:00am'
        end_time = '9:00pm'
      else
        start_time = row[START_TIME_FIELD]
      end

      begin
        start_date = "#{start_date} #{start_time}".to_datetime
      rescue Exception=>e
        @errors << "Couldn't process datetime for event with id: " + id_field
      end
      
      if row[LOCATION_FIELD].blank?
        location = [row[STREET_NUMBER], row[STREET_NUMBER_HALF], row[STREET_PREFIX], row[STREET_NAME], row[STREET_SUFFIX], row[APT_TYPE], row[APT_NO]].join(' ')
      else
        location = row[LOCATION_FIELD]
      end

      #deduplication
      if Event.find_by_start_and_location_and_postal_code start_date, row[LOCATION_FIELD], row[POSTAL_CODE_FIELD]
        @dupes << "Detected duplicate event with id: " + id_field
        next
      end

      if row[END_DATE_FIELD].blank?
        end_date = row[START_DATE_FIELD]
      else
        end_date = row[END_DATE_FIELD]
      end
     
      supress_end_time = false
      if row[END_TIME_FIELD].blank?
        end_date = "#{end_date} #{start_time}"
        begin
          end_date = end_date.to_datetime + 2.hours
        rescue
          @errors << "Couldn't process datetime for event with id: " + id_field
        end
      elsif row[END_TIME_FIELD].downcase.strip == 'null'
        end_date = "#{end_date} #{start_time}"
        end_date = end_date.to_datetime + 2.hours
        supress_end_time = true
      else
        end_time = row[END_TIME_FIELD]
        end_date = "#{end_date} #{end_time}".to_datetime
      end

      if(row[HOST_EMAIL_FIELD].blank?)
        user_email = DEFAULT_IMPORT_USER
      else
        user_email = row[HOST_EMAIL_FIELD]
        if !row[HOST_NAME_FIELD].blank?
          first_name,last_name = row[HOST_NAME_FIELD].split /\/(?=[^\/]+(?: |$))| /,2 
        elsif !row[HOST_FIRST_NAME_FIELD].blank? || !row[HOST_LAST_NAME_FIELD].blank?
          first_name = row[HOST_FIRST_NAME_FIELD]
          last_name = row[HOST_LAST_NAME_FIELD]
        else
          @errors << "No host name provided for event with id: " + id_field
        end
      end

      if not u = User.find_by_email(user_email)
        u = User.new(:email => user_email)
      end

      u.attributes = {
        :first_name => first_name,
        :last_name => last_name,
        :show_phone_on_host_profile => false,
        :site => Site.current
      }
      u.phone = row[HOST_PHONE_FIELD] unless row[HOST_PHONE_FIELD].blank?

      if not u.valid?
        @errors << "User not valid for event with id: " + id_field
      end

      e = Event.new(
        :calendar_id => calendar.id,
        :name => row[NAME_FIELD],
        :subtitle => row[SUBTITLE_FIELD],
        :description => row[DESCRIPTION_FIELD],
        :short_description => row[SHORT_DESCRIPTION_FIELD],
        :directions => row[DIRECTIONS_FIELD],
        :city => row[CITY_FIELD],
        :state => row[STATE_FIELD],
        :postal_code => row[POSTAL_CODE_FIELD],
        :fb_id => row[FB_EVENT_ID_FIELD],
        :organization => row[ORG_NAME],
        :location=> location,
        :start => start_date,
        :end => end_date,
        :supress_end_time => supress_end_time
      )
      
      e.custom_attributes_data = {:external_id => row[ID_FIELD]}
      e.locationless = true unless((row[LOCATION_FIELD] || row[STREET_NAME]) && row[CITY_FIELD] && row[STATE_FIELD] && row[POSTAL_CODE_FIELD])      
      e.suppress_email = true
      if not e.valid?
        @errors << "Event not valid for id: " + id_field
        e.errors.each do |err|
          @errors << "&nbsp;&nbsp;- "+err.inspect
        end
      end

      unless params[:category_id].blank?
        e.category = category
      end

      u.dia_group_key   = calendar.host_dia_group_key if u.dia_group_key.blank?
      u.dia_trigger_key = calendar.host_dia_trigger_key if u.dia_trigger_key.blank?

      users << u
      events << e
    end

    if @errors.empty?
      events.zip(users).each do |event, user|
        user.save
        user.sync_unless_deferred
        
        event.host_id = user.id
        event.save
      end
      if @dupes.empty?
        redirect_to :controller => 'admin', :anchor => 'calendars'
      else
        @errors.concat @dupes
        #display dupes
      end
    else
      # display errors
    end
  end

  def export
    require 'fastercsv'
    calendar = Calendar.find params[:calendar_id]
    if params[:object] == "attendees":
      events = calendar.events
      csv_string = FasterCSV.generate do |csv| 
        csv << ["INTERNATIONAL", "LOCAL", "LAST NAME", "FIRST NAME", "ADDRESS", "ADDRESS LINE 2", "CITY", "STATE", "ZIP CODE", "WORK PHONE", "HOME PHONE", "CELL PHONE", "EMAIL", "EVENT ID", "EVENT", "EVENT DATE", "EVENT HOST", "EVENT LOCATION", "EVENT CITY", "EVENT STATE", "EVENT ZIP", "EVENT EXTERNAL ID", "SHIFT", "STATUS", "VOLUNTEER ACTIVITY", "PARTNER ID"] 
        events.each do |e|
          e.attendees.each do |u|
            csv << ["null", "null", u.last_name, u.first_name, u.street, u.street_2, u.city, u.state, u.postal_code, "null", u.phone, "null", u.email, e.id, e.name, e.start, e.host.email, e.location, e.city, e.state, e.postal_code, e.fb_id, "null", "null", "null", u.partner_id] 
          end
        end
      end
    end
    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', 
      :disposition => "attachment; filename=users.csv"
  end

protected
  def authorized?
    return true if current_user.admin?
    flash[:notice] = "Must be an administrator to access this section"
    return false
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/admin', :action => 'login'
      end
    end
  end

  def can_view_calendars
    return true if current_user.site_admin?
    access_denied
  end

  def can_edit_calendars
    return true if current_user.site_admin?
    access_denied
  end

  def can_view_sponsors
    return true if current_user.site_admin?
    access_denied
  end

  def can_edit_sponsors
    return true if current_user.site_admin?
    access_denied
  end

  def can_view_permissions
    return true
  end

  def can_edit_permissions
    return true if current_user.site_admin?
    access_denied
  end

  def can_view_themes
    return true if current_user.site_admin?
    access_denied
  end

  def can_edit_themes
    return true if current_user.site_admin?
    access_denied
  end

  def can_view_site_config
    return true if current_user.site_admin?
    access_denied
  end

  def can_edit_site_config
    return true if current_user.site_admin?
    access_denied
  end

end
