class ReportSweeper < ActionController::Caching::Sweeper
  observe Report

  def after_save(report)
    event = report.event
    calendar = event.calendar 
    permalink = calendar.permalink
    expire_page(permalink, "/reports/#{event.id}") if event
    expire_page(permalink, "/events/show/#{event.id}") if event
    expire_page(permalink, "/reports/list")
    expire_page(permalink, "/reports/search/state/#{event.state}") if event && event.state
    report.attachments.each {|a| expire_page(permalink, "/reports/lightbox/#{a.id}")}
    FileUtils.rm_rf(File.join(ActionController::Base.page_cache_directory,'reports','page')) rescue Errno::ENOENT
    FileUtils.rm_rf(File.join(ActionController::Base.page_cache_directory,permalink,'reports','page')) rescue Errno::ENOENT
  end

  # writing our own expire_page 
  def expire_page(permalink, url)
    url += url.match(/\.html|\.xml$/) ? '' : '.html'
    path = File.join(ActionController::Base.page_cache_directory,url)
    perma_path = File.join(ActionController::Base.page_cache_directory,permalink,url)
    FileUtils.rm(path) if File.exists?(path)
    FileUtils.rm(perma_path) if File.exists?(perma_path)
  end

  alias after_destroy after_save
end
