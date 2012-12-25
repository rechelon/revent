require File.dirname(__FILE__) + '/../spec_helper'

describe EventSweeper do
  include CacheSpecHelpers
  describe "when an event is created" do
    before do
      ActionController::Base.page_cache_directory = File.join(RAILS_ROOT,'tmp','cache')
      Site.stub!(:current).and_return(build :site)
      # so sync to DIA does not happen
      Site.stub!(:current_config_path).and_return('tmp')
      Varnish::EventSweeper.instance.stub!(:after_create)
      @calendar = build :calendar
      @permalink = @calendar.permalink
    end

    it "should expire the calendar show page" do
      @url = "#{@calendar.permalink}/calendars/show.html"
      @url = 'index.html'
      cache_url(@url)
      page_cache_exists?(@url).should be_true
      create :event
      page_cache_expired?(@url).should be_true
    end

    it "should expire the index page" do
      @url = 'index.html'
      cache_url(@url)
      page_cache_exists?(@url).should be_true
      create :event
      page_cache_expired?(@url).should be_true
    end

    it "should expire the permalink" do
      @url = "#{@calendar.permalink}.html"
      cache_url(@url)
      page_cache_exists?(@url).should be_true
      create :event
      page_cache_expired?(@url).should be_true
    end

    it "should expire total.js" do
      @url = "events/total.js"
      cache_url(@url)
      page_cache_exists?(@url).should be_true
      create :event
      page_cache_expired?(@url).should be_true
    end

    it "should expire total.html" do
      @url = "events/total.html"
      cache_url(@url)
      page_cache_exists?(@url).should be_true
      create :event
      page_cache_expired?(@url).should be_true
    end
  end
end
