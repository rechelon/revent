namespace :db do
  desc "Dump the current database to a MySQL file" 
  task :dump do
    load 'config/environment.rb'
    configs = ActiveRecord::Base.configurations
    case configs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(configs[RAILS_ENV])
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        if configs[RAILS_ENV]["password"].blank?
          f << `mysqldump -h #{configs[RAILS_ENV]["host"]} -u #{configs[RAILS_ENV]["username"]} #{configs[RAILS_ENV]["database"]}`
        else
          f << `mysqldump -h #{configs[RAILS_ENV]["host"]} -u #{configs[RAILS_ENV]["username"]} -p#{configs[RAILS_ENV]["password"]} #{configs[RAILS_ENV]["database"]}`
        end
      end
    else
      raise "Task not supported by '#{configs[RAILS_ENV]['adapter']}'" 
    end
  end

  desc "Dump the database to a csv file"
  task :dump_csv do
    load 'config/environment.rb'
    configs = ActiveRecord::Base.configurations
    ActiveRecord::Base.establish_connection(configs[RAILS_ENV])

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

  desc "Refreshes your local development environment to the current production database" 
  task :production_data_refresh do
    `cap db:remote_runner`
    `rake db:production_data_load --trace`
    `rake revent:setup_sites --trace`
  end 

  desc "Loads the production data downloaded into db/production_data.sql into your local development database" 
  task :production_data_load do
    load 'config/environment.rb'
    configs = ActiveRecord::Base.configurations
    case configs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(configs[RAILS_ENV])
      if configs[RAILS_ENV]["password"].blank?
        `mysql -h #{configs[RAILS_ENV]["host"]} -u #{configs[RAILS_ENV]["username"]} #{configs[RAILS_ENV]["database"]} < db/production_data.sql`
      else
        `mysql -h #{configs[RAILS_ENV]["host"]} -u #{configs[RAILS_ENV]["username"]} -p#{configs[RAILS_ENV]["password"]} #{configs[RAILS_ENV]["database"]} < db/production_data.sql`
      end
    else
      raise "Task not supported by '#{configs[RAILS_ENV]['adapter']}'" 
    end
  end
end
