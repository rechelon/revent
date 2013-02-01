class RsvpSweeper < ActionController::Caching::Sweeper
  observe Rsvp

  def after_create(rsvp)
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,'events','show',"#{rsvp.event.id}.html")) rescue Errno::ENOENT    
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,rsvp.event.calendar.permalink,'events','show',"#{rsvp.event.id}.html")) rescue Errno::ENOENT
    Rails.logger.info("Expired caches for new rsvp")
  end

end
