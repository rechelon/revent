class Admin::SponsorsController < AdminController 
  before_filter :can_view_sponsors, :only => [:index]
  before_filter :can_edit_sponsors, :only => [:create, :update, :destroy]

  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#sponsors'
      end
      format.json do
        @sponsors = Sponsor.find(:all,{:conditions=>{:site_id=>Site.current.id},:include=>[:admins]})
        render :json => @sponsors
      end
    end
  end
  
  def create
    @sponsor = Sponsor.new
    update
  end

  def update
    if !@sponsor
      @sponsor = Sponsor.find(params[:id])
      params.delete :id
    end
    new_attributes = {}
    @sponsor.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    @sponsor.attributes = new_attributes
    if @sponsor.save
      render :json => @sponsor
    else
      render :json => @sponsor.errors, :status => 500
    end
  end
  
  def destroy
    begin
      @sponsor = Sponsor.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end
end
