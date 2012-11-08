namespace :dia do
  desc "Get all supporters from groups listed with calendars"
  task :get_supporters do
    raise 'You need to set an environment varibale called SITE' if ENV['SITE'].nil? or ENV['SITE'].empty?
    load 'config/environment.rb'
    DIA_ENABLED=true
    host = ENV['SITE']
    site = Site.find_by_host host
    Site.current = site
    keys = site.calendars.map {|c| c.get_supporter_group_keys} 
    keys.flatten!.uniq!
    puts keys.inspect
    keys.each do |key|
      Supporter.create_supporters_from_dia_group(key)
    end
  end
end
