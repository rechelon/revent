class EventSweeper < ActionController::Caching::Sweeper
  observe Event

  def after_create(event)
    expire_event_list_pages(event)
    RAILS_DEFAULT_LOGGER.info("Expired caches for new event")
  end

  def after_update(event)
    expire_event_pages_and_fragments(event)
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,event.calendar.permalink,'events','search','state',"#{event.state}.html")) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,event.calendar.parent.permalink,'events','search','state',"#{event.state}.html")) if event.calendar.parent rescue Errno::ENOENT
    RAILS_DEFAULT_LOGGER.info("Expired caches for updated event #{event.id}")
  end

  def after_destroy(event)
    expire_event_pages_and_fragments(event)
    expire_event_list_pages(event)
    RAILS_DEFAULT_LOGGER.info("Expired caches for deleted event #{event.id}")
  end

  protected
  def expire_event_list_pages(event)
    expire_event_permalink_list_pages(event)
    expire_event_permalink_list_pages(event, event.calendar.permalink)
    expire_event_permalink_list_pages(event, event.calendar.parent.permalink) if event.calendar.parent
  end

  def expire_event_permalink_list_pages(event, permalink="")
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,permalink,'events','search','state',"#{event.state}.html")) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,permalink,'events','flashmap.xml')) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,permalink,'events','total.js')) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,permalink,'events','total.html')) rescue Errno::ENOENT
    Cache.delete("site_#{Site.current.id}_all_events_version") rescue IndexError

    unless permalink.blank?
      FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{permalink}.html")) rescue Errno::ENOENT
      FileUtils.rm(File.join(ActionController::Base.page_cache_directory,"#{permalink}",'calendars','show.html')) rescue Errno::ENOENT
    else
      FileUtils.rm(File.join(ActionController::Base.page_cache_directory,'index.html')) rescue Errno::ENOENT
    end
  end

  def expire_event_pages_and_fragments(event)
    expire_page :controller => '/events', :action => 'show', :id => event.id, :permalink => event.calendar.permalink
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,event.calendar.permalink,'events','show',"#{event.id}.html")) rescue Errno::ENOENT
    expire_fragment "events/_report/event_#{event.id}_list_item"
    Cache.delete "event_#{event.id}_marker" rescue NameError
  end
end
