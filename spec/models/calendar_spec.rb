require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Calendar do 
  before do
    Varnish::EventSweeper.instance.stub!(:after_create)
  end
  describe 'when created' do
    before do 
      Site.current = build :site, :id => 777
      @calendar = create :calendar
      @event = create :event, :calendar => @calendar
      @report = create :report, :event => @event, :status => 'published'
      @other_calendar = create :calendar
      @other_event = create :event, :calendar => @other_calendar
      @other_report = create :report, :event => @other_event, :status => 'published', :calendar => @other_calendar
    end

    describe 'for calendars that are singular' do
      it "finds just the included events" do
        @calendar.events.should == [ @event ]
      end
      it "counts just the included events" do
        @calendar.events.size.should == 1
      end
      it "finds the reports" do
        @calendar.reports.should == [ @report ]
      end
    end

    describe 'for calendars that contain other calendars' do
      before do
        @other_calendar.parent = @calendar
        @calendar.calendars << @other_calendar
      end
      it "should contain all events from children calendars" do        
        @calendar.events.should == [ @event, @other_event ]
      end
      it "should count all events from child calendars" do        
        @calendar.events.size.should == 2
      end
      it "should support find" do        
        @calendar.events.find(:all).should == [ @event, @other_event ]
      end
      it "finds the reports" do
        @calendar.reports.should == [ @report, @other_report ]
      end
      it "finds published reports" do 
        @calendar.reports.published.should == [  @report, @other_report ]
      end
      it "doesn't find unpublished reports" do 
        @unpublished = create :report, :event => @event
        @unpublished.unpublish
        @calendar.reports.published.should_not include(@unpublished)
      end
      it "doesn't find unpublished reports on the all calendar" do
        @unpublished = create :report, :event => @other_event
        @unpublished.unpublish
        @calendar.reports.published.should_not include(@unpublished)
      end
      it "finds searchable events" do 
        @calendar.events.searchable.should == [ @event, @other_event ]
      end
      it "hides private events from search results" do 
        @private_event = create :event, :private => true, :calendar => @calendar
        @calendar.events.searchable.should_not include(@private_event)
      end
      it "hides private events from the all calendar" do
        @private_event = create :event, :private => true, :calendar => @other_calendar
        @calendar.events.searchable.should_not include(@private_event)
      end
    end
  end

  describe 'featured' do 
    before do
      Site.current = build :site, :id => 777
      @calendar = create :calendar
      @event = create :event, :calendar => @calendar
      @featured_report = create :report, :featured => true, :event => @event
    end
    it "should contain featured reports" do
      @calendar.reports.featured.should include(@featured_report)
    end
    it "not include featured reports" do
      @non_featured_report = create :report, :featured => false, :event => @event
      @calendar.reports.featured.should_not include(@non_featured_report)
    end
  end

  describe 'supporter groups' do
    before do
      @calendar = create :calendar
    end
    it 'should return an array of dia group keys' do
      @calendar.supporter_dia_group_keys = '12345,67890'
      @calendar.get_supporter_group_keys.should == ['12345','67890']
    end
    it 'should strip whitespace' do
      @calendar.supporter_dia_group_keys = ' 11111,  66666'
      @calendar.get_supporter_group_keys.should == ['11111','66666']
    end
  end

  def test_load_from_dia
    assert true
    return # unless connecting to remote, and let's get this out of here
    mock = stub(:get => [{'event_KEY' => '1111', 'Event_Name' => 'name', 'Description' => 'desc', 'Address' => 'addr', 'City' => 'city', 'State' => 'state', 'Zip' => '94110', 'Start' => 1.hour.from_now, 'End' => 2.hours.from_now, 'Directions' => 'directions', 'Default_Tracking_Code' => 'stepitup'}])    
    DIA_API_Simple.stubs(:new).returns(mock)
    assert_nil Event.find_by_service_foreign_key('1111')
    result = Calendar.load_from_dia(1)
    assert result.is_a?(Calendar::DiaLoadResult)
    e = Event.find_by_service_foreign_key('1111')
    assert e
    assert e.tags.include?(Tag.find_by_name('stepitup'))
  end
end
