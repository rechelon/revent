namespace :revent do
  desc "Load sites table with local domains"
  task :setup_sites do
    load 'config/environment.rb'
    domain = "." + ( ENV['DOMAIN'] || "local_revent.org" )
    Site.find(:all).each do |s| 
      name = s.theme || s.host[/.+\.(.+)\.[^\.]+$/,1]
      s.update_attribute(:host, name + domain) 
    end
  end

  task :consolidate_yaml do
    config_sites_dir = Rails.root.join('config','sites')
    FileUtils.mkdir_p(config_sites_dir) unless File.exists?(config_sites_dir)
    Site.find(:all).each do |site|
      config = {}
      Dir["#{Site.config_path(site.id)}/*.yml"].each do |old_config_file|
        resource = old_config_file[/(.*)-config/, 1]
        next if File.exists?(site.config_file) && 
                YAML.load_file(site.config_file)[resource]
        config[resource] = YAML.load_file(old_config_file)
      end
      File.open(site.config_file, "a") {|f| YAML.dump(config, f)}
    end
  end

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
