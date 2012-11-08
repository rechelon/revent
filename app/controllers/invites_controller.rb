class InvitesController < ActionController::Base
  def method_missing(*args)
    raise 'who called this?  die! die! die!'
  end
end
