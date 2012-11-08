require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction::API Parser" do

	before do
    @api = DemocracyInAction::API.new( api_arguments )
	end

  describe "parsing out the count" do
    it "should return the proper count" do
      xml = fixture_file_read('supporters.xml')
      @api.send(:parse, xml).count.should == 11467
    end
  end

  describe "parsing the records" do
    describe "a supporter record" do
      before do
        @supporter = fixture_file_read('supporter_by_key.xml')
      end
      it "should have a first name" do
        @api.send(:parse, @supporter).result.first['First_Name'].should == 'Homer'
      end
    end
    describe "an event record" do
      before do
        @event = fixture_file_read('event.xml')
      end
      it "should have an event name" do
        @api.send(:parse, @event).result.first['Event_Name'].should == 'Salsa Lessons Webinar:  Mar. 23, 2:00 p.m.'
      end
      it "should have some email trigger keys" do
        pending
        @api.send(:parse, @event).result.first['event$email_trigger_KEYS'].should == '0,436'
      end
    end
    it "returns an array of records" do
      @supporters = fixture_file_read('supporters.xml')
      @api.send(:parse, @supporters).result.size.should == 2
    end
  end
  describe "parsing a table description" do
    before do
      @desc = fixture_file_read('supporter_description.xml')

    end
    it "reads the table description" do
      @api.send(:parse, @desc, DemocracyInAction::DIA_Desc_Listener).result[:supporter_KEY].key.should == 'PRI'
    end
  end

end
