begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pp'
require 'democracy_in_action'
require 'democracy_in_action/test_methods'
require 'spec/have_the_same_xml_structure'
require 'spec/be_the_same_list'
Spec::Runner.configure do |config|

  config.include(XmlStructureMatcher)
  config.include(AggregateMatchers)
  DemocracyInAction::API.send :include, DemocracyInAction::TestMethods
  DemocracyInAction::API.disable!

  def api_arguments
    user = ENV['DIA_USER'] || 'dummy'
    pass = ENV['DIA_PASS'] || 'secret'
    node = ENV['DIA_NODE'] || :salsa
    {:username => user, :password => pass, :node => node }
  end
  def working_api_arguments
    user = ENV['DIA_USER'] || 'demo'
    pass = ENV['DIA_PASS'] || 'demo'
    node = ENV['DIA_DOMAIN'] || :sandbox
    {:username => user, :password => pass, :node => node }
  end

  def fixture_file_read(filename)
    @@fixture_responses ||= {}
    @@fixture_responses[filename] ||= File.read(File.dirname(__FILE__) + '/fixtures/' + filename)
  end

end
