require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rsvp do
  before do
    initialize_site
    @event = create :event, :calendar => @calendar, :country_code => 'GBR'
    @user = create :user, :site => @site
  end

  describe "when created" do
    before do
      @rsvp = create :rsvp, :user => @user, :event => @event
    end

    it "should send an email" do
      @trigger = create :trigger, :email_plain => 'test email', :from => 'testy mctesterson', :name => 'RSVP Thank You', :calendar => @calendar
      TriggerMailer.should_receive :deliver_trigger
      @rsvp.trigger_email
    end

    describe "user" do
      it "should be an attendee for the event" do
        @event.attendees.include?(@user).should == true
      end
    end
  end
end
