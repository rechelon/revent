class CacheController < ApplicationController

  def clear_calendars
    Site.current.calendars.each do |c|
      CalendarSweeper::clear_calendars c
    end
    render :nothing =>true
  end

end
