class Admin::CategoriesController < AdminController 
  def create
    @category = Category.new
    new_attributes = {}
    @category.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    @category.attributes = new_attributes
    if @category.save
      render :json => @category
    else
      render :json => @category.errors, :status => 500
    end    
  end
  
  def update
    @category = Category.find(params[:id])
    params.delete :id
    new_attributes = {}
    @category.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    if @category.update_attributes(new_attributes)
      render :json => @category
    else
      render :json => @category.errors, :status => 500
    end    
  end
    
  def destroy
    begin
      @event = Category.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end  
end
