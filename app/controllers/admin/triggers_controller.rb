class Admin::TriggersController < AdminController 
  def create
    @trigger = Trigger.new
    new_attributes = {}
    @trigger.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    @trigger.attributes = new_attributes
    if @trigger.save
      render :json => @trigger
    else
      render :json => @trigger.errors, :status => 500
    end    
  end
  
  def update
    @trigger = Trigger.find(params[:id])
    params.delete :id
    new_attributes = {}
    @trigger.attribute_names.each{|key| new_attributes[key] = params[key]  unless params[key].nil? }    
    if @trigger.update_attributes(new_attributes)
      render :json => @trigger
    else
      render :json => @trigger.errors, :status => 500
    end    
  end
    
  def destroy
    begin
      @event = Trigger.destroy(params[:id])
      render :json => {:id=>params[:id]}
    rescue => e
      render :text => e.message, :status => 500
    end
  end  
end