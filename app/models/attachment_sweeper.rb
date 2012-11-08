class AttachmentSweeper < ActionController::Caching::Sweeper
  observe Attachment

  def after_create(record)
    return unless record.event
    expire_event_show_page(record.event)
    #RAILS_DEFAULT_LOGGER.info("Expired caches for new attachment")
  end

  def after_update(record)
    return unless record.event
    expire_event_show_page(record.event)
    #RAILS_DEFAULT_LOGGER.info("Expired caches for updated attachment #{record.id}")
  end

  def after_destroy(record)
    return unless record.event
    expire_event_show_page(record.event)
    #RAILS_DEFAULT_LOGGER.info("Expired caches for deleted attachment #{record.id}")
  end

  def expire_event_show_page(event)
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,event.calendar.permalink,'events','show',"#{event.id}.html")) rescue Errno::ENOENT
    FileUtils.rm(File.join(ActionController::Base.page_cache_directory,'events','show',"#{event.id}.html")) rescue Errno::ENOENT
  end
end
