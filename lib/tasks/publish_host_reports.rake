namespace :reports do
  desc "Publish reports where reporter email matches host email"
  task :publish_host_reports do
    raise 'You need to set an environment varibale called SITE' if ENV['SITE'].nil? or ENV['SITE'].empty?

    load 'config/environment.rb'
    Site.current = Site.find_by_host ENV['SITE']
    Host.current = ENV['SITE']
    c = Calendar.find_by_permalink 'weareone'
    i = 0;
    c.events.each do |e| 
      e.exportable_reports.each do |r| 
        next if r.published? 
        if r.user.email.to_s == r.event.host.email.to_s
          r.status = Report::PUBLISHED
          r.save
          i = i + 1 
          puts i
        end
      end 
    end 
    puts i.to_s+' reports published'
  end 
end