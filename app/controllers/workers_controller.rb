class WorkersController < ApplicationController
  before_filter :access_control

  def access_control
    if request.env['REMOTE_ADDR'] != SHORTLINE_IP
      redirect_to '/'
    end
  end
end
