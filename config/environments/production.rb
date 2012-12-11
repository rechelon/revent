# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Need to disable caching of templates for multisite plugin (i.e. theme_support)
# to work.  This does not effect page caching.
config.action_view.cache_template_loading = false

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = false 

config.active_record.verification_timeout = 14400

# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.smtp_settings = actionmailer_options "production"

DIA_ENABLED = true

config.cache_store = :dalli_store, MEMCACHE_SERVERS,
  { :namespace => 'revent_production', :compress => true }
require 'memcache_util'

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We're in smart spawning mode.
     CACHE.reset 
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end 
end
