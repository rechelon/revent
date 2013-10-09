namespace :revent do
  desc "Change the hostnames of all hosts to the .local tld, nil out all salsa keys"
  task :create_local do
    load 'config/environment.rb'

    hostnames = []
    Host.find(:all).each do |h|
      if /\.localhost$/.match(h.hostname).nil?
        h.hostname = h.hostname + '.localhost'
        print h.hostname
        hostnames << h.hostname
        h.save
      end
    end

    unless hostnames.count == 0
      puts ""
      puts "Please add the following line to your hosts file (usually /etc/hosts):"
      puts ""
      puts "127.0.0.1\t"+hostnames.join(" ")
    end

    Host.generate_shortline_script("/tmp/revent_shortline.sh", "127.0.0.1")
    puts ""
    puts "A shortline script has been generated for this configuration, please run it: /tmp/revent_shortline.sh"

    Calendar.find(:all).each do |c|
      c.rsvp_dia_group_key = nil
      c.rsvp_dia_trigger_key = nil
      c.report_dia_group_key = nil
      c.report_dia_trigger_key = nil
      c.host_dia_trigger_key = nil
      c.host_dia_group_key = nil
      c.supporter_dia_group_keys = nil
      c.save
    end

    puts ""
    puts "All salsa keys have been cleared"

    puts ""
    puts "Please change your webserver configuration accordingly"
  end

  desc "Get mollom statistics for each site with mollom enabled"
  task :get_mollom_stats do
    load 'config/environment.rb'
    Site.all.each do |s|
      unless s.config.mollom_api_public_key.nil? or s.config.mollom_api_private_key.nil?
        m = Mollom.new :private_key => s.config.mollom_api_private_key, :public_key => s.config.mollom_api_public_key
        total_days = m.statistics :type => 'total_days'
        total_accepted = m.statistics :type => 'total_accepted'
        total_rejected = m.statistics :type => 'total_rejected'
        total_percent = total_accepted + total_rejected == 0 ? 0 : (total_rejected.to_f / (total_accepted + total_rejected).to_f).round(4) * 100
        yesterday_accepted = m.statistics :type => 'yesterday_accepted'
        yesterday_rejected = m.statistics :type => 'yesterday_rejected'
        yesterday_percent = yesterday_accepted + yesterday_rejected == 0 ? 0 : (yesterday_rejected.to_f / (yesterday_accepted + yesterday_rejected).to_f).round(4) * 100
        today_accepted = m.statistics :type => 'today_accepted'
        today_rejected = m.statistics :type => 'today_rejected'
        today_percent = today_accepted + today_rejected == 0 ? 0 : (today_rejected.to_f / (today_accepted + today_rejected).to_f).round(4) * 100
        puts "\n"
        puts "Site: "+s.name
        puts "Total days operational: "+total_days.to_s
        puts "==========================="
        puts "Total accepted: "+total_accepted.to_s
        puts "Total rejected: "+total_rejected.to_s
        puts "Total spam %: "+total_percent.to_s
        puts "---------------------------"
        puts "Yesterday accepted: "+yesterday_accepted.to_s
        puts "Yesterday rejected: "+yesterday_rejected.to_s
        puts "Yesterday spam %: "+yesterday_percent.to_s
        puts "---------------------------"
        puts "Today accepted: "+today_accepted.to_s
        puts "Today rejected: "+today_rejected.to_s
        puts "Today spam %: "+today_percent.to_s
        puts "\n"
      end
    end
  end

  desc "Get users who have created events in a specified calendar"
  task :get_users_for_calendar, :'calendar permalink' do |t, args|
    load 'config/environment.rb'
    c = Calendar.find_by_permalink(args[:'calendar permalink'])
    users = []
    FasterCSV.open("/tmp/revent_users_export.csv", "w") do |csv|
      csv << ["ID", "Email", "Created", "First Name", "Last Name", "Phone #", "Address", "Address 2", "City", "State", "Postal Code", "Country", "Partner ID", "Facebook ID", "Twitter ID", "Organization", "# of events"]
      c.events.each do |e|
        u = e.host
        unless users.include? u
          users << u
          csv << [u.id.to_s, u.email.to_s, u.created_at.to_s, u.first_name.to_s, u.last_name.to_s, u.phone.to_s, u.street.to_s, u.street_2.to_s, u.city.to_s, u.state.to_s, u.postal_code.to_s, u.country_code.to_s, u.partner_id.to_s, u.fb_id.to_s, u.twitter_id.to_s, u.organization.to_s, u.events.count]
        end
      end
    end
  end
end
