require_dependency 'user'
require_dependency 'democracy_in_action_object'

class Workers::UsersController < WorkersController
  def index
    logger.info("running user worker******")
    @user = User.find(params[:id])
    raise "cant find a user with id #{params[:id]}" unless @user.id

    if !@user.valid?
      raise 'invalid user: validation error'
      return false
    end 
    
    if params[:dia]
      @user[:democracy_in_action] = params[:dia]
    end

    @user.background_processes
    render :nothing => true
  end 
 
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
