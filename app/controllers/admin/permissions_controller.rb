class Admin::PermissionsController < AdminController
  before_filter :can_view_permissions, :only => [:index]
  before_filter :can_edit_permissions, :only => [:create, :update, :destroy]

  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#permissions'
      end
      format.json do
        #@permissions = UserPermission.find(:all,{:conditions=>{:site_id=>Site.current.id},:include=>[:admins]})
        #render :json => @permissions
      end
    end
  end

  def create
    @permission = UserPermission.new
    update
  end

  def update
    if !@permission
      @permission = UserPermission.find(params[:id])
      params.delete :id
    end
    new_attributes = {}
    @permission.attribute_names.each{|key| new_attributes[key] = params[key] if !params[key].nil? }
    @permission.attributes = new_attributes
    if @permission.save
      render :json => @permission
    else
      render :json => @permission.errors, :status => 500
    end
  end

  def destroy
    begin
      @permission = UserPermission.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end

end
