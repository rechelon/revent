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
end
