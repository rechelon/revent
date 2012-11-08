class Admin::CachesController < AdminController
  
  def destroy
    if request.method == :delete
      %x[rm -rf #{RAILS_ROOT}/public/cache/#{Site.current.host.hostname}/*]
      flash[:notice] = "Cache has been cleared"
    end
    redirect_to :back
  end
end
