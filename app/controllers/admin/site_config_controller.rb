class Admin::SiteConfigController < AdminController
  before_filter :can_view_site_config, :only => [:index]
  before_filter :can_edit_site_config, :only => [:update]

  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#site'
      end
      format.json do
        render :json => Host.current.site.config.as_json
      end
    end
  end

  def update
  end
end
