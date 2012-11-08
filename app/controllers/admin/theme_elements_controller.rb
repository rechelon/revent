class Admin::ThemeElementsController < AdminController
  before_filter :can_view_themes, :only => [:index]
  before_filter :can_edit_themes, :only => [:create, :update, :destroy]
  def create
    @theme_element = ThemeElement.new
    new_attributes = {}
    @theme_element.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    @theme_element.attributes = new_attributes
    if @theme_element.save
      render :json => @theme_element
    else
      render :json => @theme_element.errors, :status => 500
    end    
  end
  
  def update
    @theme_element = ThemeElement.find(params[:id])
    params.delete :id
    new_attributes = {}
    @theme_element.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    if @theme_element.update_attributes(new_attributes)
      render :json => @theme_element
    else
      render :json => @theme_element.errors, :status => 500
    end    
  end
    
  def destroy
    begin
      @theme_element = ThemeElement.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end  

end
