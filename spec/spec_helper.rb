require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'cache_spec_helper'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    config.include CacheCustomMatchers
    config.include AuthenticatedTestHelper

    config.include FactoryGirl::Syntax::Methods

  end

  def initialize_site( *args )
    opts = args.first || {}
    @site = opts['current_site'] || create(:site)
    @host = opts['current_host'] || create(:host, :site => @site)
    Site.current = @site
    Host.current = @host
    @calendar = opts['calendar'] || create(:calendar, :site => @site)
    @site.stub!(:calendars).and_return([@calendar])
    @site.config.salsa_user = SALSA_TEST_ACCOUNT[:user]
    @site.config.salsa_pass = SALSA_TEST_ACCOUNT[:pass]
    @site.config.salsa_node = SALSA_TEST_ACCOUNT[:node]
    @site.save!
    Site.stub!(:current).and_return(@site)
    Site.stub!(:current_config_path).and_return(Rails.root.join('test', 'config'))
    request.stub!(:host).and_return(Host.current.hostname) if defined?(request)
  end

  def test_uploaded_file(file = 'arrow.jpg', content_type = 'image/jpg')
    ActionController::TestUploadedFile.new(Rails.root.join('spec', 'fixtures', 'attachments', file), content_type)
  end

  def truncate_float(fl, precision)
    factor = 10.0 ** precision
    ( (fl * factor).floor ) / factor
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

end


