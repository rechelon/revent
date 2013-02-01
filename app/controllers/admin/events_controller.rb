class Admin::EventsController < AdminController
  include EventAPI

  before_filter :can_crud_event, :only => [:update, :destroy]
  cache_sweeper :event_sweeper, :only => :create

  def index
    params[:restrict_to_admins] = 'true'
    params[:send_x_headers] = 'true'
    respond_to do |format|
      format.html do
        redirect_to '/admin#events'
      end
      format.json do
        render :json => fetch_events(params)
      end
    end
  end
  
  def create
    @event = Event.new
    update
    if !current_user.site_admin?
      if current_user.user_permissions_data[:sponsor_admin].length > 0
        sponsors = Sponsor.find(:all, :conditions=>{:id=>current_user.user_permissions_data[:sponsor_admin]})
        sponsors.each do |s|
          s.events << @event unless s.events.include? @event
        end
      end
    end
  end
    
  def update
    new_attributes = {}
    @event.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    @event.attributes = new_attributes
    if @event.host_user_email != params[:host_user_email]
      @event.host_user_email = params[:host_user_email]
    end
    if @event.save
      @event.sync_unless_deferred
      if params[:custom_attributes].respond_to? :each
        params[:custom_attributes].each do |attribute|
          if !attribute['id'].blank?
            @event.custom_attributes.find(attribute['id']).update_attributes(attribute)
          else
            @event.custom_attributes.create(attribute)
          end
        end
      end
      @event.reload
      render :json => @event
    else
      render :json => @event.errors, :status => 500
    end
  end
  
  def destroy
    begin
      @event.destroy
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end

  def alert_nearby_supporters
    @trigger = @calendar.triggers.find_by_name('Email Nearby Supporters About New Event')

    if @trigger.nil? 
      render :text => 'Before you can use this feature, you need to create the following email trigger:<br><br>"Email Nearby Supporters About New Event" '
      return
    end

    @event = @calendar.events.find(params[:id])
    @supporters = Supporter.near_event( @event )    
    render :layout => :none
  end

  def alert_nearby_supporters_again
    redirect_to :action => :email_nearby_supporters, :params => params
  end

  def email_nearby_supporters
    trigger = Trigger.new(params[:trigger])
    trigger.email_html = nil if trigger.email_html == ''

    event = @calendar.events.find(params[:event_id])

    supporters = []
    params[:supporters].each do |supporter_id|
      supporter = Supporter.find(supporter_id)
      TriggerMailer.trigger(trigger, supporter, event).deliver
      trigger.bcc = ''
    end

    event.update_attribute :emailed_nearby_supporters, true 

    flash[:notice] = 'Email sent to nearby supporters of event '+event.name
    redirect_to :action => :index
  end

# TED: not sure what is using this, leaving it in
  def list
    if request.format == Mime::XML
      xml_options = { :include => 
                      { :attendees => { :include => :custom_attributes },
                        :host =>      { :include => :custom_attributes }, 
                        :reports =>   { :include => {:user => {:include => :custom_attributes}}}
                      },
                      :except => [:crypted_password, :activation_code, :salt, :password_reset_code]
                    }
      if params[:updated_since] && start_time = Time.parse( params[:updated_since ] )
        @events = @calendar.events.find_updated_since(start_time)
      else
        @events = @calendar.events
      end
      render :xml => @events.to_xml(xml_options)
    else
      super
    end
  end

  def export
    params[:restrict_to_admins] = "true"
    params[:limit] = 8000

    @events = fetch_events params

    require 'fastercsv'
    string = FasterCSV.generate do |csv|
      header_row = ["Event ID", "Event Name", "Event URL", "Start Date", "Start Time", "Address", "City", "State", 
       	      "Postal Code", "District", "Directions","Short Description", "Long Description", "Host Name", "Host Email", "Host Phone", 
	            "Host Address", "RSVP","Report Backs","High Attendees", "Low Attendees", "Average Attendees", "Organized/Sponsored by", "Created At","Private","Worksite Event"]
      header_row.concat Site.current.config.custom_attributes unless Site.current.config.custom_attributes.nil?
      custom_event_fields = @events.inject([]) {|names, u| names << u.custom_attributes.map {|a| a.name }; names.flatten.compact.uniq }
      header_row.concat custom_event_fields
      csv << header_row
      @events.each do |event|
        host = event.host
        url = "http://"+Host.current.hostname+"/"+event.calendar.permalink+"/events/show/"+event.id.to_s
        row = [event.id, event.name, url, event.start.strftime("%m/%d/%Y"), event.start_time, 
                event.location, event.city, event.state, event.postal_code, event.district,
                event.directions, event.short_description, event.description,
                (host ? host.full_name : nil), (host ? host.email : nil), (host ? host.phone : nil), 
                (host ? host.address : nil), event.rsvps.count,event.reports.count, event.attendees_high, 
                event.attendees_low, event.attendees_average, event.organization, 
                event.created_at.to_s(:db), (event.private ? 'yes' : 'no'), (event.worksite_event) ]

        custom_fields = Array.new(Site.current.config.custom_attributes.length)
        if !host.nil?
          host.custom_attributes.each do |attribute|
          index = Site.current.config.custom_attributes.index(attribute.name)
          custom_fields[index] = attribute.value unless index.nil?
        end
        end
        row.concat custom_fields
        row.concat custom_event_fields.map {|a| event.custom_attributes_data.send(a.to_sym) }
        csv << row
      end
    end
    send_data(string, :type => 'text/csv; charset=utf-8; header=present', :filename => "events.csv")
  end  

  def mail_merge
    @calendar = Calendar.find_by_permalink(params[:permalink])
    render :layout => false
  end

private
  
  def can_crud_event
    @event = Event.find(params[:id])
    if !current_user.site_admin?
      continue = false
      sponsors = Sponsor.find(:all, :conditions=>{:id=>current_user.user_permissions_data[:sponsor_admin]})
      sponsors.each do |s|
        if s.events.include? @event
          continue = true
          break
        end
      end
      return unless continue
    end
  end
end
