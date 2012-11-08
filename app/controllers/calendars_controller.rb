class CalendarsController < ApplicationController
  caches_page_unless_flash :show

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create ],
         :redirect_to => { :action => :list }

  def show
    # map data
    redirect_to '/'+@calendar.permalink+'/' if params[:permalink].nil?
    @map_width= (params['map_width'] || '560')+'px'
    @map_height= (params['map_height'] || '400')+'px'

    if @calendar.map_engine == "osm"
      @osm_key = Host.current.cloudmade_api_key;
    end
    @icons = {
      :icon_upcoming => @calendar.icon_upcoming || Site.current.config.icon_upcoming,
      :icon_past => @calendar.icon_past || Site.current.config.icon_past,
      :icon_worksite => @calendar.icon_worksite || Site.current.config.icon_worksite
    }
  end
  
  def num_users
    render :inline => Site.current.users.length.to_s
  end

  def embed
    self.show
    render :layout => 'clean' 
  end
end
