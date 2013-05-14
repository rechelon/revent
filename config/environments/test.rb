Revent::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.cache_store = :dalli_store, *(MEMCACHE_SERVERS + [{ :namespace => 'revent_test', :compress => true }])

end

DIA_ENABLED = true  

# allow ENV to populate test credentials, for travis-ci
SALSA_TEST_ACCOUNT[:user] = ENV['SALSA_TEST_USER'] unless ENV['SALSA_TEST_USER'].blank?
SALSA_TEST_ACCOUNT[:pass] = ENV['SALSA_TEST_PASS'] unless ENV['SALSA_TEST_PASS'].blank?
SALSA_TEST_ACCOUNT[:node] = ENV['SALSA_TEST_NODE'] unless ENV['SALSA_TEST_NODE'].blank?

MOLLOM_TEST_ACCOUNT[:public_key] = ENV['MOLLOM_TEST_PUBLIC_KEY'] unless ENV['MOLLOM_TEST_PUBLIC_KEY'].blank?
MOLLOM_TEST_ACCOUNT[:private_key] = ENV['MOLLOM_TEST_PRIVATE_KEY'] unless ENV['MOLLOM_TEST_PRIVATE_KEY'].blank?

$test_fog = {
  :credentials => {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_TEST_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_TEST_SECRET_ACCESS_KEY']
  },
  :directory => ENV['AWS_TEST_DIR'],
  :force_path_for_aws => true
} unless ENV['AWS_TEST_ACCESS_KEY_ID'].blank? or ENV['AWS_TEST_SECRET_ACCESS_KEY'].blank? or ENV['AWS_TEST_DIR'].blank?
