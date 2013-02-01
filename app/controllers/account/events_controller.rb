class Account::EventsController < AccountControllerShared

  # login_required calls authorized? (at bottom of this file) 
  # which sets up @event for any method in this controller to use
  before_filter :login_required
  cache_sweeper :event_sweeper, :only => [:update, :remove, :upload]
  #verify :method => :post, :only => [:update, :remove, :upload], :redirect_to => {:action => 'index'}

  def index
    @hosting = current_user.events
    @attending = current_user.attending
    @current_user = current_user
  end

  def show
    extend ActionView::Helpers::TextHelper
    @nearby_events = @event.nearby_events
    @blog = Blog.new(:event => @event)
    #added by margot needs peer review
    @categories = @calendar.categories.map {|c| [c.name, c.id] }
    @event.render_scripts   # render letter/call scripts
    require 'ostruct'
    @invite = OpenStruct.new(:recipients => nil, :subject => @event.calendar.attendee_invite_subject, :body => @event.calendar.attendee_invite_message)
    @liquid[:union_form] = render_to_string :partial => '/events/union_form'
    unless Site.current.config.custom_event_options['targets_official'].nil?
      @liquid[:elected_official_form] = render_to_string :partial => '/events/elected_official_form'
    end
    @liquid[:nonviolent_form] = render_to_string :partial => '/events/nonviolent_form'
  end

  def upload
    if !params[:attachment][:uploaded_data].blank? && @event.attachments.create!(params[:attachment])
      flash[:notice] = "Upload successful"
    else
      flash[:error] = "Upload failed"
    end
    redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event
  end

  def update
    begin
      redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event and return unless params[:event]
      @event.attributes = params[:event]

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

      if @event.valid?
        @event.time_tbd = params[:tbd] if params[:tbd]
        @event.host_alias = params[:event_host] ? false : true
        @event.save!
        @event.sync_unless_deferred
      else
        flash.now[:error] = 'There was a problem updating your event - please double check your information and try again.' 
        render :action => 'show', :id => @event
        return
      end 
      if params[:event][:letter_script] || params[:event][:call_script]
        update_campaign_scripts(@event) if params[:event][:letter_script]
        flash[:notice] = 'Invitation script(s) updated.'
      else
        flash[:notice] = 'Event updated'
      end
      respond_to do |format|
        format.html do 
          redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event
        end
        format.json do 
          render :json => @event.to_json
        end
      end

      logger.info 'updated attributes'
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = 'Error: Event Invalid'
      show
      render :permalink => @calendar.permalink, :action => 'show', :id => @event
    end
  end

  def save_fb_connect_id
    return false unless params[:id] && params[:fb_id]
    @event = Event.find(params[:id])
    @event.fb_id = params[:fb_id]
    @event.save
    @event.sync_unless_deferred
    render :json => @event.to_json
  end
  
  def update_campaign_scripts(event)
    objects = DemocracyInActionObject.find(:all, :from => "democracy_in_action_objects as d",
      :conditions => ["d.table = ? AND associated_type = ? AND associated_id = ?", 'campaign', 'Event', event.id])
    objects.each do |o|
      c = DemocracyInActionCampaign.find(o.key)
      c.Suggested_Content = event.letter_script
      c.save
    end
  end  

  def invite
    unless (params[:invite] && params[:invite][:recipients] && params[:invite][:subject] && params[:invite][:body])
      flash[:notice] = 'Must provide recipient emails (separated by commas), subject, and message for invitations.'
      redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event and return
    end
    UserMailer.invite(current_user.email, @event, params[:invite]).deliver
    flash[:notice] = 'Invites delivered'
    redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event
  end

  def message
    UserMailer.message(current_user.email, @event, params[:message]).deliver
    flash[:notice] = 'Email delivered'
    redirect_to :permalink => @calendar.permalink, :action => 'show', :id => @event
  end

  def destroy
    if @event.host_id != current_user.id
      flash[:error] = 'Unauthorized action'  
      manage_account_path(:permalink => @calendar.permalink)
      return
    end
    @event.destroy
    flash[:notice] = 'Event deleted'
    redirect_to manage_account_path(:permalink => @calendar.permalink)
  end

  def remove
    @rsvp = @event.rsvps.find(:first, :conditions => {:user_id => current_user.id})
    @rsvp.destroy
    flash[:notice] = 'RSVP removed'
    redirect_to :action => 'index'
  end

  def attendees
    require 'fastercsv'
    string = FasterCSV.generate do |csv|
      csv << ["Email", "First_Name", "Last_Name", "Phone"]
      (@event.attendees || @event.to_democracy_in_action_event.attendees.collect {|a| User.new :email => a.Email, :first_name => a.First_Name, :last_name => a.Last_Name, :phone => a.Phone}).each do |sup|
        csv << [sup.email, sup.first_name, sup.last_name, sup.phone]
      end
    end
    send_data(string, :type => 'text/csv; charset=utf-8; header=present', :filename => "event_#{@event.id}_attendees.csv")
  end

  protected
  def authorized?
    return true if %w(index).include?(action_name)
    @event = Event.find(params[:id])
    return true if current_user.admin?
    if %w(remove).include?(action_name)
      return true if current_user.attending.include?(@event)
    end
    return true if current_user.events.include?(@event)
    false
  end
end
