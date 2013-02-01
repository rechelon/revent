# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.16' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Bootstrap application pre-initialization
require 'memcache'
require File.join(RAILS_ROOT, 'lib', 'us_state_constants')
require File.join(RAILS_ROOT, 'lib', 'report_api_module')
require File.join(RAILS_ROOT, 'lib', 'event_api_module')
require File.join(RAILS_ROOT, 'lib', 'event_import_module')
require File.join(RAILS_ROOT, 'config', 'revent_config')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  config.autoload_paths += %W( #{RAILS_ROOT}/vendor/democracy_in_action/lib )

  config.action_controller.session_store = :active_record_store

  config.active_record.observers = :event_sweeper, :rsvp_sweeper, :calendar_sweeper, :attachment_sweeper, :report_sweeper, :'varnish/event_sweeper', :'varnish/theme_element_sweeper'
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /^(.*) of (.*)/i, '\1s of \2'
end

# Include your application configuration below
require 'democracy_in_action'
require 'base64'
require 'cgi'
require 'openssl'
require 'sanitize'
require 'tlsmail'
Net::SMTP.enable_tls( OpenSSL::SSL::VERIFY_NONE)
require File.join(RAILS_ROOT, 'lib', 'scrub')
require File.join(RAILS_ROOT, 'lib', 'shortline')

initialize_geocoders
