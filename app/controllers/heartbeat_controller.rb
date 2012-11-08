class HeartbeatController < ActionController::Base
  def index
    render :text => 'OK', :layout => false
  end
end
