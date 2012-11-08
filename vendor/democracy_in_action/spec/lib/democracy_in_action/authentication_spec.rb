require File.dirname(__FILE__) + "/../../spec_helper"

describe DemocracyInAction::API do
  describe "when authenticating" do
    describe "with invalid credentials" do
      before do
        @api = DemocracyInAction::API.new( api_arguments ) 
        @api.stub!(:authentication_request).and_return(fixture_file_read('invalid_auth.xml'))
      end
      it "should return false" do
        lambda { @api.authenticate }.should raise_error
      end
      it "should return false in authenticated?" do
        @api.authenticate rescue DemocracyInAction::API::ConnectionInvalid
        @api.authenticated?.should be_false
      end
      it "should raise an error" do
        pending
        lambda {@api.authenticate}.should raise_error
      end
    end
    describe "with valid credentials" do
      describe "authenticate" do
        before do
          @api = DemocracyInAction::API.new( working_api_arguments )
          @api.stub!(:authentication_request).and_return(fixture_file_read('valid_auth.xml'))
        end
        it "should return true" do
          @api.authenticate.should_not be_nil
        end
        it "should not raise error" do
          lambda { @api.authenticate }.should_not raise_error
        end
        it "should return true in authenticated?" do
          @api.authenticate
          @api.authenticated?.should be_true
        end
      end
    end
  end
end
