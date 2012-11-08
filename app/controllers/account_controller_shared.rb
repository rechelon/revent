class AccountControllerShared < ApplicationController
=begin
  def get_theme
    if current_user
      theme = current_user.effective_calendar.theme
      return theme if theme
    end
    super
  end
=end
end
