class Admin::ThemesController < AdminController
  before_filter :can_view_themes, :only => [:index]
  before_filter :can_edit_themes, :only => [:create, :update, :destroy, :clone]

  def index
    respond_to do |format|
      format.html do
        redirect_to '/admin#themes'
      end
      format.json do
        @themes = Theme.find(:all,{:conditions=>{:site_id=>Site.current.id}},:include=>[:elements])
        render :json => @themes.to_json(:include => :elements)
      end
    end
  end

  def create
    @theme = Theme.new
    new_attributes = {}
    @theme.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    @theme.attributes = new_attributes
    if @theme.save
      render :json => @theme
    else
      render :json => @theme.errors, :status => 500
    end    
  end

  def update
    @theme = Theme.find(params[:id])
    params.delete :id
    new_attributes = {}
    @theme.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    if @theme.update_attributes(new_attributes)
      render :json => @theme
    else
      render :json => @theme.errors, :status => 500
    end    
  end

  def destroy
    begin
      @theme = Theme.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end

  def clone
    @theme = Theme.find(params[:id])
    @cloned_theme = Theme.new(:name => params[:name], :site_id => @theme.site_id)
    @theme.elements.each do |e|
      t = ThemeElement.new(:name => e.name, :markdown => e.markdown)
      t.save
      @cloned_theme.elements << t
    end
    if @cloned_theme.save
      render :json => @cloned_theme
    else
      render :json => @theme.errors, :status => 500
    end
  end

end
