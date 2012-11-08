require File.dirname(__FILE__) + '/../spec_helper'

if 'true' == ENV['REMOTE']
  describe DemocracyInActionEvent do
    before do
      now = Time.now.to_i
      @event = DemocracyInActionEvent.new(:Event_Name => "Test Event #{now}")
      @key = @event.save
    end
    it "can find" do
      event = DemocracyInActionEvent.find(@key)
      event.Event_Name.should == @event.Event_Name
      @event.destroy
    end
    it "can destroy" do
      @event.destroy
      DemocracyInActionEvent.find(@key).should_not be_true
    end
  end
end

