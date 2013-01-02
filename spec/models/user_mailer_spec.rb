require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
  before do
    Site.current = Site.new(:host => 'revent.local')
    @user = build :user
    initialize_site
  end 

  it "uses the calendar admin email" do
    Site.current.stub!(:calendars).and_return([build :calendar, :admin_email => 'info@radicaldesigns.org'])
    response = UserMailer.create_activation(@user)
    assert_equal('info@radicaldesigns.org', response.from[0])
  end
  
  describe "events in time" do
    before do
      @event = build :event, :id => 333, :name => 'Step It Up Rally', :city => 'San Francisco', :state => 'CA', :location => '1370 Mission St., 4th Fl.', :start => 1.day.ago, :end => (1.day.ago + 2.hours)
      @message = {:subject => 'check, check, testing, 1, 2, 3', :body => 'test upcoming/past events'}
    end
    it "knows if event is in the past" do
      response = UserMailer.create_message(@from, @event, @message)
      response.body.should match(/took place on/)
    end
    it "knows if event is in the future" do
      @event.start = 1.day.from_now
      @event.end = 1.day.from_now + 2.hours
      response = UserMailer.create_message(@from, @event, @message)
      response.body.should match(/will take place on/)
    end
  end
end
