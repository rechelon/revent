require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Event do 
  before do
    Varnish::EventSweeper.instance.stub!(:after_create)
    Site.current = build :site, :id => 1
    Site.stub!(:current_config_path).and_return(Rails.root.join('test', 'config'))

    # mock geocoder
    @geo = stub('geo', [:coordinates => [77.7777, -111.1111], :precision => "ROOFTOP"])

    Geocoder.stub!(:search).and_return(@geo)

    # mock democracy in action api
    @dia_api = stub('dia_api', :save => true, :authenticate => true)
    DemocracyInActionEvent.stub!(:api).and_return(@dia_api)
    
    @event = build :event
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
      @event2 = build :event, :worksite_event => true
      @event2.save!
      Event.not_private.find(:all).should(include(@event))
      Event.not_private.find(:all).should(include(@event2))
    end
  end
end
