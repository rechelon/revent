class SiteController < ApplicationController
  skip_before_filter :set_site, :set_calendar, :only => :splash
  def index
    if Calendar.any?
      redirect_to :action => 'list'
    else
      redirect_to :action => 'create_site'
    end
    #list
    #render :action => 'list'
  end

  def list
    @sites = Site.find(:all)
    render :inline => 'in list', :layout => true
    # @site_pages, @sites = paginate :sites, :per_page => 10
  end
  
  def show
    @site = site.find(params[:id])
  end

  def new
    @site = Site.new
  end
  
  def splash
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      flash[:notice] = 'Site was successfully created!'      
    end
    redirect_to :action => 'list'
    # render :text => 'in create_site', :layout => true
  end
  
  def edit
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = 'Site was successfully updated.'
      redirect_to :action => 'show', :id => @site
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    Site.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
