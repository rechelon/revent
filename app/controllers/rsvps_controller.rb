class RsvpsController < ApplicationController
  after_filter :cors_set_access_control_headers

  include RsvpAPI

  def index
    params[:limit] = 8000

    @rsvps = fetch_rsvps params

    respond_to do |format|
      format.json do
        render :json => @rsvps.as_json(Event::MAP_JSON)
      end
      format.html do
        render :json => @rsvps.as_json(Event::MAP_JSON)
        #render :text => '.json and .rss formats only'
      end
      format.rss do
        render :layout => false
      end
    end
  end

end
