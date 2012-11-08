class ConfigTableCreate < ActiveRecord::Migration
  def self.up
    create_table :site_configs do |t|
      t.integer :site_id
      t.boolean :calendar_list_upcoming_events, :default=>false
      t.boolean :calendar_list_worksite_events, :default=>false
      t.integer :calendar_list_upcoming_events_limit, :default=>5
      t.integer :calendar_list_upcoming_events_xml_limit, :default=>100
      t.integer :nearby_supporter_radius, :default=>25
      t.string  :fb_app_id
      t.string  :fb_app_secret
      t.string  :google_oauth_key
      t.string  :google_oauth_secret
      t.string  :twitter_oauth_key
      t.string  :twitter_oauth_secret
      t.boolean :is_akismet_enabled, :default=>false
      t.string  :akismet_api_key
      t.string  :akismet_domain_name
      t.boolean :enable_recaptcha, :default=>true
      t.boolean :event_thank_you_page, :default=>false
      t.boolean :delay_dia_sync, :default=>false
      t.string  :varnish_server_url
      t.text    :custom_attributes_raw
      t.text    :required_custom_attributes_raw
      t.text    :custom_attributes_options_raw
      t.text    :custom_event_attributes_raw
      t.text    :custom_event_options_raw
    end
  end

  def self.down
    drop_table :site_configs
  end
end
