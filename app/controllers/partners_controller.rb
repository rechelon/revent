class PartnersController < ApplicationController
  #skip_before_filter :calendar
  #skip_before_filter :set_cache_root

  before_filter :set_partner_cookie
  def set_partner_cookie
    cookies[:partner_id] = {:value => params[:id], :expires => 3.hours.from_now} if params[:id]
  end
  before_filter(:only => :index) {|c| c.request.env["HTTP_IF_MODIFIED_SINCE"] = nil} #don't 304
  caches_action :index
  def index
    if params[:redirect]
      redirect_to params[:redirect]
    elsif params[:event_id]
      redirect_to :permalink => @calendar.permalink, :controller => 'events', :action => 'show', :id => params[:event_id], :format => nil 
    elsif Site.current.partner_redirect_url
      redirect_to Site.current.partner_redirect_url
    else
      redirect_to home_url
    end
  end

end
