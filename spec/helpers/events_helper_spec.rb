require File.dirname(__FILE__) + '/../spec_helper.rb'

describe EventsHelper do
  it "should event date range" do
    event = stub('event', :time_tbd? => false, :supress_end_time? => false, :start? => true, :start => Date.new(2008, 1, 1), :end => Date.new(2008, 1, 2), :time_zone => nil)
    helper.event_date_range(event).should_not be_empty
  end
end
