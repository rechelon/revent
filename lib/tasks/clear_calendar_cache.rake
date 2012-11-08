namespace :cache do
  desc "Clear the calendar cache for all sites"
  task :clear_calendar do
    load 'config/environment.rb'
    Site.find(:all).each do |s|
      Site.current = s
      controller = CacheController.new
      controller.clear_calendars
    end
  end
end
