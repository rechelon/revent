require File.dirname(__FILE__) + "/../../spec_helper"


describe DemocracyInAction::API do
  before do
    @api = DemocracyInAction::API.new( api_arguments ) 
    #Net::HTTP::Post.stub!(:new).and_return(stub_everything)
  end

  describe "build_body" do
    it "should convert key value pair into string" do
      body = @api.send(:build_body, {"key" => "123456"})
      body.should =~ /key=123456/
    end
    it "should convert multiple key value pairs into string" do
      body = @api.send(:build_body, {"key" => "123456", "email" => "test@domain.org"})
      body.should =~ /key=123456&email=test%40domain.org/
    end
    it "should convert key value pairs that contain arrays into string" do
      body = @api.send(:build_body, {"key" => "123456", "names" => ["austin", "adam", "seth"]})
      body.should =~ /names=austin&names=adam&names=seth&key=123456/
    end
  end

  describe "get" do

    describe "with multiple keys" do
      it "doesn't change requests without keys" do
        start_hash = { 'test' => 5, "blah" => 2 }
        @api.send(:param_key, start_hash.dup ).should == {}
      end
      it "doesn't change singular keys" do
        start_hash = { 'test' => 5, "blah" => 2, :key => "scram" }
        @api.send(:param_key, start_hash.dup ).should == { :key => 'scram' }
      end
      it "changes arrays of keys" do
        start_hash = { 'test' => 5, "blah" => 2, 'key' => [ "scram", 'suckah'] }
        @api.send(:param_key, start_hash.dup ).should_not == start_hash
      end
      it "changes arrays of keys to comma-delimited strings" do
        start_hash = { 'test' => 5, "blah" => 2, 'key' => [ "scram", 'suckah'] }
        @api.send(:param_key, start_hash.dup )['key'].should == "scram, suckah"
      end
    end

    describe "with options_for_get" do
      it "should call param_key" do
        @api.should_receive(:param_key).and_return({})
        @api.send(:options_for_get, {} )
      end
      it "should call param_condition" do
        @api.should_receive(:param_condition).and_return({})
        @api.send(:options_for_get, {} )
      end

      describe "a :condition parameter with a hash" do
        it "should convert to an array" do
          ( @api.send(:options_for_get, { :object => 'test', :condition => { :Email => 'joe@example.com', :Last_Name => 'Biden' }})[:condition] - [ 'Last_Name=Biden','Email=joe@example.com']).should be_empty
        end
      end

      describe "a :condition parameter with a string" do
        it "makes no changes" do
          simple_condition =  "Email = 'joe@example.com' AND Last_Name => 'Biden'"
          @api.send(:options_for_get, { :condition => simple_condition })[:condition].should == simple_condition
        end
        
      end
  
    end
  end

  describe "process" do
    describe "link hash" do
      it "raises an empty array unless it is passed a hash" do
        lambda{ @api.send(:param_link_hash, "blech")}.should raise_error(DemocracyInAction::API::InvalidData)
      end
      it "returns a hash" do
        @api.send(:param_link_hash, {} ).should be_an_instance_of(Array)
      end
      it "returns an array with the key and value pairs joined" do
        @api.send(:param_link_hash, { 'test' => '5'} ).join('&').should == 'link=test&linkKey=5'
      end
      it "returns an array with the key and value pairs joined, and value arrays processed with the keys duplicated" do
        @api.send(:param_link_hash, { 'test' => [5, 6, 7] } ).should == [ 'link=test&linkKey=5','link=test&linkKey=6','link=test&linkKey=7']
      end
      it "handles multiple table names" do
        @api.send(:param_link_hash, 
                  { 'fail' => [72,19], 
                    'test' => [5, 6, 7] } ).should have_same_elements(
                    [ 'link=test&linkKey=5', 
                      'link=test&linkKey=6', 
                      'link=test&linkKey=7',
                      'link=fail&linkKey=19', 
                      'link=fail&linkKey=72'] )
      end
      it "gets the right stuff back after build body" do
        @api.send(:build_body, :link => { 'test' => [5, 6, 7]} ).should =~ /link=test&linkKey=5&link=test&linkKey=6&link=test&linkKey=7/
      end
    end
    describe "process_process_options" do
      it "should call process options to process the options" do
        @api.should_receive(:param_link_hash).with({"hello" => "i love you"}).and_return([])
        @api.send(:build_body, { :link => {"hello" => "i love you"}})
      end
    end
  end

  describe "send Request" do
    it "build body returns a string containing the passed options" do
      @api.send(:build_body, {:cheese => 'brutal', :object => 'noodle'}).should match(/noodle/)
    end
  end

  describe "RESTful API methods" do
    it "supports POST" do
      @api.should_receive(:save)
      @api.supporter.post
    end
    it "supports PUT" do
      @api.should_receive(:save)
      @api.supporter.put :key => 'test'
    end

    describe "PUT" do
      it "won't work unless a key is specified" do
	      lambda{@api.supporter.put}.should raise_error( DemocracyInAction::API::InvalidKey )
      end
      it "will also work with supporter and email" do
	      lambda{@api.supporter.put :Email => 1 }.should_not raise_error( DemocracyInAction::API::InvalidKey )
      end

      it "will also work with *_KEY" do
	      lambda{@api.supporter.put :supporter_KEY => 1 }.should_not raise_error( DemocracyInAction::API::InvalidKey )
      end
    end
    
  end
end
