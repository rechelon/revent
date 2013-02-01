namespace :db do
  desc "Dump the current database to a MySQL file" 
  task :dump do
    load 'config/environment.rb'
    configs = ActiveRecord::Base.configurations
    case configs[Rails.env]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(configs[Rails.env])
      File.open("db/#{Rails.env}_data.sql", "w+") do |f|
        if configs[Rails.env]["password"].blank?
          f << `mysqldump -h #{configs[Rails.env]["host"]} -u #{configs[Rails.env]["username"]} #{configs[Rails.env]["database"]}`
        else
          f << `mysqldump -h #{configs[Rails.env]["host"]} -u #{configs[Rails.env]["username"]} -p#{configs[Rails.env]["password"]} #{configs[Rails.env]["database"]}`
        end
      end
    else
      raise "Task not supported by '#{configs[Rails.env]['adapter']}'" 
    end
  end

  desc "Dump the database to a csv file"
  task :dump_csv do
    load 'config/environment.rb'
    configs = ActiveRecord::Base.configurations
    ActiveRecord::Base.establish_connection(configs[Rails.env])

    require 'fastercsv'
    hostname = ENV["SITE"] 
    dump_file_name = ENV["CSV"]
    raise 'use this like rake db:dump_csv SITE=hostname CSV=dump_file_name' unless hostname and dump_file_name
    events = Site.find_by_host(hostname).events.find :all, :include => :host
    headers = events.first.attributes.keys
    user_headers = events.first.host.attributes.keys
    csv_headers = headers + user_headers.map { |h| "user_#{h}" }
    
    FasterCSV.open( dump_file_name, 'w' ) do |csv|
      csv << csv_headers
      events.each do |event|
        values = headers.map { |h| event[h] }
        values += user_headers.map { |h| event.host[h] }
        csv << values
      end
    end
  end
end
