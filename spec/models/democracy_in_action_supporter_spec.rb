require File.dirname(__FILE__) + '/../spec_helper'

describe DemocracyInActionSupporter do
  describe "when authenticating" do
    before do
      @supporter= stub('supporter', :Email => 'test@test.com', :Password => Digest::MD5.hexdigest('password'))
      DemocracyInActionSupporter.stub!(:find).and_return(@supporter)
    end
    it "authenticates with correct password" do
      DemocracyInActionSupporter.authenticate('test@test.com', 'password').should == @supporter
    end
    it "fails to authenticate with incorrect password" do
      DemocracyInActionSupporter.authenticate('test@test.com', 'wrongpassword').should be_nil
    end
  end
  if 'true' == ENV['REMOTE']
    describe "when saving" do
      before do
        @now = Time.now.to_i
        @supporter = DemocracyInActionSupporter.new(:Email => "seth+#{now}@radicaldesigns.org", :First_Name => 'testing', :Last_Name => @now)
        @key = @supporter.save
      end
      it "finds" do
        supporter = DemocracyInActionSupporter.find(@key)
        supporter.First_Name.should == 'testing'
        supporter.Last_Name.should == @now.to_s
      end
      it "destroys" do
        @supporter.destroy
        DemocracyInActionSupporter.find(@key).should_not be_true
      end
    end
  end
end
