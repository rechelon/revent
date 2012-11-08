# NOTE: @calendar refers to current default calendar set in ApplicationController#set_site
#       don't use it to refer to a local calendar variable
class Admin::CalendarsController < AdminController 
  before_filter :can_view_calendars, :only => [:index]
  before_filter :can_edit_calendars, :only => [:create, :update, :destroy, :set_default]

  cache_sweeper :calendar_sweeper, :only => :update

  def before_update_save(record)
    record.event_end = nil if params[:never] == '1'
  end
  
  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#calendars'
      end
      format.json do
        @calendars = Calendar.find(:all,{:conditions=>{:site_id=>Site.current.id},:include=>[:hostform,:triggers,:categories]})
        render :json => @calendars
      end
    end
  end
  
  def create
    @c = Calendar.new
    new_attributes = {}
    @c.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    @c.attributes = new_attributes
    if @c.save
      render :json => @c
    else
      render :json => @c.errors, :status => 500
    end    
  end
  
  def update
    @c = Calendar.find(:first, {:conditions=>{:id=>params[:id], :site_id => Site.current.id},:include=>:hostform})
    params.delete :id
    params.delete :site_id
    @c.build_hostform if !@c.hostform
    @c.hostform.attributes = params[:hostform] if !params[:hostform].blank?
    new_attributes = {}
    @c.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    if @c.update_attributes(new_attributes)
      render :json => @c
    else
      render :json => @c.errors, :status => 500
    end
  end
  
=begin #this is too dangerous for clients to actually have
  def destroy
    begin
      @c = Calendar.find(:one, {:id=>params[:id], :site_id => Site.current.id})
      @c.destroy
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end
=end

  def set_default
    render(:text =>'calendar already current', :status=>500) and return if params[:id].to_s == @calendar.id.to_s
    @new_default = Calendar.find(:first, {:conditions=>{:id=>params[:id], :site_id => Site.current.id}})
    render( :text => "could not find calendar", :status => 500) and return if @new_default.nil?
    begin
      @new_default.update_attribute :current, true
      @calendar.update_attribute :current, false
      render :json => {:current_default=>@new_default.id, :previous_default=>@calendar.id}
    rescue => e
      render :text => e.message, :status => 500
    end
  end

  def conditions_for_collection
    [ "site_id = ?", Site.current.id ]
  end
end
