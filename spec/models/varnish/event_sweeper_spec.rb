require File.dirname(__FILE__) + '/../../spec_helper'

describe Varnish::EventSweeper do
  before do
    Site.stub!(:current).and_return(build :site)
    Host.stub!(:current).and_return(build :host)
    Site.current.hosts << Host.current
    @calendar = create :calendar, :permalink => "something"
    @parent_calendar = create :calendar, :permalink => "everything", :calendars => [@calendar]
  end

  describe "when an event is created" do
    it "should determine the correct purge routes" do
      next_event_id = ActiveRecord::Base.connection.execute("SHOW TABLE STATUS LIKE 'events'").fetch_hash['Auto_increment']
      Varnish::EventSweeper.instance.should_receive(:purges).with(construct_routes(next_event_id)).and_return([])
      create :event, :calendar => @calendar
    end
    it "should call the purging method" do
      Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
      create :event, :calendar => @calendar
    end
  end

  describe "when an event" do
    before do
      @event = create :event, :calendar => @calendar
    end
    
    describe "is updated" do
      it "should determine the correct purge routes" do
        Varnish::EventSweeper.instance.should_receive(:purges).with(construct_routes(@event.id.to_s)).and_return([])
        @event.name = "Some new title"
        @event.save
      end
      it "should call the purging method" do
        Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
        @event.name = "Some new title"
        @event.save
      end
    end

    describe "is destroyed" do
      it "should determine the correct purge routes" do
        Varnish::EventSweeper.instance.should_receive(:purges).with(construct_routes(@event.id.to_s)).and_return([])
        @event.destroy
      end
      it "should call the purging method" do
        Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
        @event.destroy
      end
    end
  end

  def construct_routes event_id
    ['everything/maps', 'everything/events/show/'+event_id, 'something/maps', 'something/events/show/'+event_id]
  end

end
