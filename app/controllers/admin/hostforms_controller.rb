class Admin::HostformsController < AdminController 
  def conditions_for_collection
    [ "hostforms.site_id = ?", Site.current.id ]
  end
  
  def before_create_save(hostform)
    hostform.site_id = Site.current.id
  end
end


