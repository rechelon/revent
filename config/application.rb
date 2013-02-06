require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Bootstrap application pre-initialization
require File.expand_path('../../lib/us_state_constants', __FILE__)
require File.expand_path('../../lib/report_api_module', __FILE__)
require File.expand_path('../../lib/event_api_module', __FILE__)
require File.expand_path('../../lib/event_import_module', __FILE__)
require File.expand_path('../../config/revent_config', __FILE__)

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Revent
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.autoload_paths += [Rails.root.join("vendor","democracy_in_action","lib"), Rails.root.join("lib")]

    config.active_record.observers = :event_sweeper, :rsvp_sweeper, :calendar_sweeper, :attachment_sweeper, :report_sweeper, :'varnish/event_sweeper', :'varnish/theme_element_sweeper'

  end

  ActiveSupport::Inflector.inflections do |inflect|
    inflect.plural /^(.*) of (.*)/i, '\1s of \2'
  end

end

#require 'democracy_in_action'
require 'base64'
require 'cgi'
require 'openssl'
require 'sanitize'
require 'tlsmail'
Net::SMTP.enable_tls( OpenSSL::SSL::VERIFY_NONE)
require Rails.root.join('lib', 'scrub')
require Rails.root.join('lib', 'shortline')

ActionMailer::Base.smtp_settings = actionmailer_options Rails.env

initialize_geocoders
initialize_uploads Rails.env
