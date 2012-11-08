require_dependency 'user'
require_dependency 'democracy_in_action_object'

class UserWorker < Struct.new(:user_id)
  def perform
    logger.info("running delayed Job******")
    raise "cant find a user with id #{user_id}" unless user.id

    Site.current = user.site
    Host.current = user.site.host

    if !user.valid?
      raise 'invalid user: validation error'
      return false
    end 

    user.background_processes
  end 
 
  def user
    @user ||= User.find(user_id, :include=>:site)
  end
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
