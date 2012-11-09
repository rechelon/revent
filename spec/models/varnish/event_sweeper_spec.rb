require File.dirname(__FILE__) + '/../../spec_helper'

describe Varnish::EventSweeper do
  before do
    Site.stub!(:current).and_return new_site
    Host.stub!(:current).and_return new_host
    Site.current.hosts << Host.current
    @calendar = new_calendar
  end

  describe "when an event is created" do
    it "should expire the maps ajax cache" do
      Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
      create_event
    end
  end

  describe "when an event" do
    before do
      @event = create_event
    end
    
    describe "is updated" do
      it "should expire the maps ajax cache" do
        Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
        @event.name = "Some new title"
        @event.save
      end
    end

    describe "is destroyed" do
      it "should expire the maps ajax cache" do
        Varnish::EventSweeper.instance.should_receive(:hydra_run_requests)
        @event.destroy
      end
    end
  end
end
