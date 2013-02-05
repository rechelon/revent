require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails.root)
require 'spec/autorun'
require 'spec/rails'
require 'ostruct'
require 'cache_spec_helper'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = Rails.root.join 'spec', 'fixtures'
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
