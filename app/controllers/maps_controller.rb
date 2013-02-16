class MapsController < ApplicationController
  include EventAPI

  def index
    params[:realhosts] = true
    params[:limit] = 8000
    params[:order] = 'start-asc'
    params[:show_private_events] = 'false'
    params[:calendar] = @calendar

    @events = fetch_events params

    respond_to do |format|
      format.json do
        render :json => @events.as_json(Event::MAP_JSON)
      end
      format.html do
        render :json => @events.as_json(Event::MAP_JSON)
        #render :text => '.json and .rss formats only'
      end
      format.rss do
        render :layout => false
      end
    end
  end

end
