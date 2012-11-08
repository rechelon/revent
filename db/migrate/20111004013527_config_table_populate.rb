class ConfigTablePopulate < ActiveRecord::Migration
  def self.up
    Site.find(:all).each do |s|
      Site.current = s
      Object.send(:remove_const,'ReventConfig')
      revent_config_path = File.join(Site.current_config_path, 'revent_config.rb')
      if File.exists? revent_config_path
        load revent_config_path
      else
        load 'config/initializers/revent_config.rb'
      end
      options = {}
      options[:site_id] = s.id
      if ReventConfig.respond_to? :calendar_list_upcoming_events
        options[:calendar_list_upcoming_events] = ReventConfig.calendar_list_upcoming_events()
      end
      if ReventConfig.respond_to? :calendar_list_worksite_events
        options[:calendar_list_worksite_events] = ReventConfig.calendar_list_worksite_events()
      end
      if ReventConfig.respond_to? :calendar_list_upcoming_events_limit
        options[:calendar_list_upcoming_events_limit] = ReventConfig.calendar_list_upcoming_events_limit()
      end
      if ReventConfig.respond_to? :calendar_list_upcoming_events_xml_limit
        options[:calendar_list_upcoming_events_xml_limit] = ReventConfig.calendar_list_upcoming_events_xml_limit()
      end
      if ReventConfig.respond_to? :nearby_supporter_radius
        options[:nearby_supporter_radius] = ReventConfig.nearby_supporter_radius()
      end
      if ReventConfig.respond_to? :fb_app_id
        options[:fb_app_id] = ReventConfig.fb_app_id().to_s
      end
      if ReventConfig.respond_to? :fb_app_secret
        options[:fb_app_secret] = ReventConfig.fb_app_secret()
      end
      if ReventConfig.respond_to? :google_oauth_key
        options[:google_oauth_key] = ReventConfig.google_oauth_key()
      end
      if ReventConfig.respond_to? :google_oauth_secret
        options[:google_oauth_secret] = ReventConfig.google_oauth_secret()
      end
      if ReventConfig.respond_to? :twitter_oauth_key
        options[:twitter_oauth_key] = ReventConfig.twitter_oauth_key()
      end
      if ReventConfig.respond_to? :twitter_oauth_secret
        options[:twitter_oauth_secret] = ReventConfig.twitter_oauth_secret()
      end
      if ReventConfig.respond_to? :akismet_enabled?
        options[:is_akismet_enabled] = ReventConfig.akismet_enabled?()
      end
      if ReventConfig.respond_to? :akismet_api_key
        options[:akismet_api_key] = ReventConfig.akismet_api_key()
      end
      if ReventConfig.respond_to? :akismet_domain_name
        options[:akismet_domain_name] = ReventConfig.akismet_domain_name()
      end
      if ReventConfig.respond_to? :enable_recaptcha
        options[:enable_recaptcha] = ReventConfig.enable_recaptcha()
      end
      if ReventConfig.respond_to? :event_thank_you_page
        options[:event_thank_you_page] = ReventConfig.event_thank_you_page()
      end
      if ReventConfig.respond_to? :delay_dia_sync
        options[:delay_dia_sync] = ReventConfig.delay_dia_sync()
      end
      if ReventConfig.respond_to? :varnish_server_url
        options[:varnish_server_url] = ReventConfig.varnish_server_url()
      end
      if ReventConfig.respond_to? :custom_attributes
        options[:custom_attributes_raw] = ReventConfig.custom_attributes.join(',')
      end
      if ReventConfig.respond_to? :required_custom_attributes
        options[:required_custom_attributes_raw] = ReventConfig.required_custom_attributes.join(',')
      end
      if ReventConfig.respond_to? :custom_attributes_options
        options[:custom_attributes_options_raw] = Marshal::dump ReventConfig.custom_attributes_options
      end
      if ReventConfig.respond_to? :custom_event_attributes
        options[:custom_event_attributes_raw] = ReventConfig.custom_event_attributes.join(',')
      end
      if ReventConfig.respond_to? :custom_event_options
        options[:custom_event_options_raw] = Marshal::dump ReventConfig.custom_event_options
      end
      sc = SiteConfig.new options
      sc.save
    end
  end

  def self.down
    SiteConfig.find(:all).each do |sc|
      sc.destroy
    end
  end
end
