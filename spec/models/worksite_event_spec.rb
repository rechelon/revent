require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Event do 
  before do
    Site.current = new_site(:id => 1)
    Site.stub!(:current_config_path).and_return(File.join(RAILS_ROOT, 'test', 'config'))

    # mock geocoder
    @geo = stub('geo', :lat => 77.7777, :lng => -111.1111, :precision => "street", :success => true)
    GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(@geo)

    # mock democracy in action api
    @dia_api = stub('dia_api', :save => true, :authenticate => true)
    DemocracyInActionEvent.stub!(:api).and_return(@dia_api)
    
    @event = new_event
    @event.stub!(:set_district).and_return(true)
  end

  describe 'worksite events' do
    it "should not show up when finding all searchable events" do
      @event.worksite_event = true
      @event.save!
      Event.searchable.find(:all).should_not include @event
    end

    it "should show up when finding all worksite events" do
      @event.worksite_event = true
      @event.save!
      Event.worksite.find(:all).should include @event
    end
    it "should show up when finding all worksite events" do
      @event.save!
      Event.worksite.find(:all).should_not include @event
    end
  end

  describe 'public events' do
    it "should not include private events" do
      @event.private = true
      @event.save
      Event.not_private.find(:all).should_not(include(@event))
    end
    it "should include worksite events and non-private events" do
      @event.save
      @event2 = new_event :worksite_event => true
      @event2.save!
      Event.not_private.find(:all).should(include(@event))
      Event.not_private.find(:all).should(include(@event2))
    end
  end
end
