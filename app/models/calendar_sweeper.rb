class CalendarSweeper < ActionController::Caching::Sweeper
  observe Calendar

  def after_save(calendar)
    Cache.delete("site_for_host_#{calendar.site.host}") rescue NameError
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{calendar.permalink}.html")) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{calendar.parent.permalink}.html")) if calendar.parent rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"index.html")) rescue Errno::ENOENT
  end

  def self.clear_calendars(calendar)
    Cache.delete("site_for_host_#{calendar.site.host}") rescue NameError
    cached_page = File.join(ActionController::Base.page_cache_directory,"#{calendar.permalink}.html")
    puts "Deleting #{cached_page}"
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{calendar.permalink}.html")) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{calendar.parent.permalink}.html")) if calendar.parent rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"index.html")) rescue Errno::ENOENT
  end

end
