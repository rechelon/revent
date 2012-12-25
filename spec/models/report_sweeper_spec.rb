require File.dirname(__FILE__) + '/../spec_helper'

describe ReportSweeper do
  include CacheSpecHelpers
  include CacheCustomMatchers
  before do
    test_cache_dir = File.join(RAILS_ROOT, 'tmp', 'cache', 'local_revent.org')
    File.exists?(test_cache_dir) ? FileUtils.rm_rf(test_cache_dir) : FileUtils.mkdir_p(test_cache_dir)
    ActionController::Base.page_cache_directory = test_cache_dir
    ActionController::Base.perform_caching = true
    # Sweepers are Singletons and are instantiated at the beginning of the rspec test. As such you can get to it via MySweeperClass.instance()
    Varnish::EventSweeper.instance.stub!(:after_create)
  end
  describe "on create" do
    before do 
      Site.current = build :site, :id => 1
      @event = create :event
      permalink = @event.calendar.permalink
      @urls = [ 
        "/#{permalink}/reports/#{@event.id}.html",
        "/#{permalink}/events/show/#{@event.id}.html"
      ]
      cache_urls(*@urls)
    end
    it "should delete the reports show page" do
#      lambda { create(:report, :event => @event) }.should expire_pages(@urls)
      report = create :report, :event => @event
      report.process!
      @expired_pages, @unexpired_pages = @urls.partition {|u| page_cache_expired?(u)} 
      @expired_pages.should == @urls
    end
  end
  #describe "on save" # do; end
  #describe "on destroy" #do; end
end
