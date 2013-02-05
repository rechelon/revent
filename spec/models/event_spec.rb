require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Event do 
  before do
    initialize_site

    # mock geocoder
    @geo = stub('geo', [:coordinates => [77.7777, -111.1111], :precision => "ROOFTOP"])

    Geocoder.stub!(:search).and_return(@geo)

    # mock democracy in action api
    @dia_api = stub('dia_api', :save => true, :authenticate => true)
    DemocracyInActionEvent.stub!(:api).and_return(@dia_api)
    
    @event = build :event
    @event.stub!(:set_district).and_return(true)
  end

  describe "finding by query" do
    before do
      @event.save!
      Site.current.stub!(:calendars).and_return([@event.calendar])
    end
    it "finds by calendar id" do
      @events = Event.searchable.by_query(:calendar_id => @event.calendar_id).find :all
      @events.should include(@event)
    end

    it "finds by state" do
      @event.update_attribute :state, 'CA'
      @events = Event.searchable.by_query( :state => 'CA' ).find :all
      @events.should include(@event)
    end

    it "finds by category" do
      cat = Category.create :name => 'servicenation'
      @event.update_attribute :category_id, cat.id
      @events = Event.by_query( :category_id => cat.id )
      @events.should include(@event)
    end

    it "finds by permalink" do
      @event.calendar.update_attribute :permalink, 'jenkey'
      Event.by_query( :permalink => 'jenkey').should include( @event )
    end

    it "should not find private events" do
      @event.update_attribute :private, true
      Event.searchable.by_query( :private => true ).should_not include(@event)
    end

    it "should be compatible with will_paginate" do
      create :event
      Event.by_query({ }).paginate(:all, :page => 1, :per_page => 1).length.should == 1
    end

    it "should accept some predefined sorting needs" do
      cat = create :category, :name => 'green jobs'
      categorized = create :event, :category_id => cat.id
      Event.by_query({}).prioritize(:first_category => cat.id ).first.should == categorized
    end

    it "works with child calendars" do
      parent_calendar = create :calendar
      parent_calendar.calendars << @event.calendar
      parent_calendar.save!
      Event.by_query( :calendar_id => parent_calendar.id ).should include(@event)
    end

    it "works on the calendar association" do
      other_cal_event = create :event
      @event.calendar.events.prioritize(nil).should_not include( other_cal_event )
    end

    it "does not affect the search to have an empty prioritize block" do
      ev = create :event, :state => 'WI'
      Event.prioritize(nil).by_query(:state => 'CA').should_not include(ev)
    end
  end

  describe 'in US' do
    before do
      @event.country = "United States of America"
      @event.city = "San Francisco"
      @event.postal_code = "94114"
    end
    it "should have a valid US state" do
      @event.state = 'BC'
      @event.should_not be_valid
    end
    it "should have a valid US zip" do
      @event.postal_code = 'V9N-231'
      @event.should_not be_valid
    end
    it "should be mappable" do
      @event.save
      @event.latitude.should == 77.7777 and @event.longitude.should == -111.1111
    end
  end
  describe 'in Canada' do
    before do
      @event.country = "Canada"
      @event.state = "BC"
      @event.postal_code = "V6B-3N9"
    end
    it "should have a valid Canadian province" do
      @event.state = 'CA'
      @event.should_not be_valid
    end
    it "should have a valid Canadian postal code" do
      @event.postal_code = '10001'
      @event.should_not be_valid
    end
    it "should be mappable" do
      @event.save
      @event.latitude.should == 77.7777 and @event.longitude.should == -111.1111
    end
  end
  describe "outside US and Canada" do
    before do
      @event.country = "Iran"
    end
    it "does not need a valid state" do
      @event.state = nil
      @event.should be_valid 
    end
    it "does not need a valid postal code" do
      @event.postal_code = nil
      @event.should be_valid 
    end
    it "does not need to be mappable" do
      @event.latitude, @event.longitude = nil, nil
      @event.should be_valid 
    end
  end
  it "should be convertible to DemocracyInActionEvent resource" do
    @event.to_democracy_in_action_event.should be_an_instance_of(DemocracyInActionEvent)
  end

  describe 'when created' do
    it "should push event to Democracy In Action" do
      pending #this test is stupid
      @dia_api.should_receive(:process).and_return(true)
      @event.save
    end
  end

  describe 'when updated' do
  end

  describe 'when destroyed' do
    before do
      Site.current = build :site
      #Site.current.stub!(:salesforce_enabled?).and_return(true)
      #SalesforceWorker.stub!(:async_save_event).and_return(true)

      #@salesforce_object = stub('sf_object', :remote_id => '444HHH', :destroy => true)
      #@event.stub!(:salesforce_object).and_return(@salesforce_object)

      DemocracyInAction::API.stub!(:new).and_return(@dia_api)
      @event.stub!(:democracy_in_action_object).and_return(mock('object', :destroy => true, :key => 111))
      @dia_api.stub!(:delete)
    end
    it "should not be in the db" do
      @event.save
      Event.find(@event.id).should_not be_nil
      @event.destroy
      lambda {Event.find(@event.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should delete event in Democracy In Action if it exists" do
      @dia_api.should_receive(:delete)
      @event.destroy
    end
  end

  it "should calculate duration of event in minutes" do
    now = Time.now
    @event = Event.new(:start => now, :end => now + 2.hours)
    @event.duration_in_minutes.should == 120
  end

  describe "congressional district" do
    before do
      @event = build :event, :postal_code => '94114', :country_code => Event::COUNTRY_CODE_USA
      Cache.stub!(:get).and_yield
    end
    it "should set the congressional districts when saved" do
      @xml = "<?xml version=\"1.0\"?><data><entry id=\"radicaldesigns\"><address1></address1><address2></address2><region>CA</region><city>Oakland</city><latitude>37.824444</latitude><longitude>-122.230556</longitude><postal_code>94618</postal_code><postal_code_extension></postal_code_extension><district>CA09</district><regional_senate_district></regional_senate_district><regional_house_district></regional_house_district></entry></data>"
      Kernel.stub!(:open).and_return(@xml)
      @event.save
      @event.district.should == "CA09"
    end
    it "should select the first congressional district" do
      @xml = "<?xml version=\"1.0\"?><data><entry id=\"radicaldesigns\"><address1></address1><address2></address2><region>CA</region><city>San Francisco</city><latitude>37.759122</latitude><longitude>-122.438712</longitude><postal_code>94114</postal_code><postal_code_extension></postal_code_extension><district>CA08</district><district>CA12</district><multidistrict>true</multidistrict><regional_senate_district></regional_senate_district><regional_house_district></regional_house_district></entry></data>"
      Kernel.stub!(:open).and_return(@xml)
      @event.save
      @event.district.should == "CA08"
    end
  end

  it "shows nearby events" do
    @event.nearby_events.should be_empty
  end
  
  it 'can set start and end datetimes from seperate date and time strings' do
    @event.set_start_from_date_and_time('08/09/2011','08:00 AM')
    @event.set_end_from_date_and_time('08/10/2011','09:00 PM')
    @event.start.strftime('%m/%d/%Y %I:%M %p').should == '08/09/2011 08:00 AM'
    @event.end.strftime('%m/%d/%Y %I:%M %p').should == '08/10/2011 09:00 PM'
  end
  describe 'when locationless' do
    it 'should be valid if no_location is true' do
      event = build :event, :postal_code => nil, :location => nil, :city => nil, :state => nil, :locationless => true
      event.valid?.should be_true
    end
  end
end
