require File.dirname(__FILE__) + '/../../spec_helper'

describe DemocracyInAction::API do
  before do
    @api = DemocracyInAction::API.new( api_arguments )
    @api.validate_connection
  end

  it "knows when it is connected" do
    api = DemocracyInAction::API.new( working_api_arguments )
    api.stub!(:authentication_request).and_return(fixture_file_read('valid_auth.xml'))
    api.should be_connected
  end

  it "it is not connected when passed bad arguments" do
    api = DemocracyInAction::API.new( api_arguments )
    api.stub!(:authentication_request).and_return(fixture_file_read('invalid_auth.xml'))
    api.should_not be_connected
  end

  describe "test methods" do
    before do
      @api = DemocracyInAction::API.new api_arguments
      @api.disable!
    end
    it "send_request raises DisabledConnectionException if disabled" do
      lambda { @api.send :send_request, 'url', :object => 'object' }.should raise_error( DemocracyInAction::API::DisabledConnectionException )
    end
    it "send_request can be stubbed to return any value" do
      @api.stub!(:send_request).and_return('bananas')
      @api.send(:send_request, 'url', :object => 'object').should == 'bananas'
    end
  end

  describe "validate" do
    api_arguments.each do |key, value| 
      it "sets attribute #{key} to equal the passed value" do
        @api.send(key).should == value
      end
    end

    it "assigns urls based on the passed node" do
      @api = DemocracyInAction::API.new( api_arguments ) 
      @api.validate_connection
      @api.urls.should == DemocracyInAction::API::NODES[api_arguments[:node]]
    end

    it "raises an error if an unsupported node is passed" do
      @api.instance_variable_set(:@node, :joe)
      @api.instance_variable_set(:@urls, nil)
      lambda { @api.validate_connection }.should raise_error
    end

    describe "accepts custom urls in place of a node" do
      before do
        @args = api_arguments.dup
        @args.delete(:node)
      end
      it "raises an error if the urls are bad" do
        #TODO(adam): Too much nesting, perhpps setup fresh connection object?
        #TODO(adam): Rework nest to not require instance_variable_set
        @api.instance_variable_set(:@urls, {:joe => 'bears'})
        @api.instance_variable_set(:@nodes, nil)
        lambda {@api.validate_connection}.should raise_error( DemocracyInAction::API::ConnectionInvalid )
      end
      it "raises no error if all required urls are given" do
        lambda {DemocracyInAction::API.new( @args.merge({ :urls => { :get => 'cares', :save => 'bears', :delete => 'cubs' }}) ) }.should_not raise_error( DemocracyInAction::API::ConnectionInvalid )
      end
    end

  end

  it "gets data from DIA" do
    @api.stub!(:send_request).and_return( fixture_file_read('supporter_by_limit_1.xml'))
    result = @api.get(:object => 'supporter', 'limit' => 1).first
    result['key'].should match( /^\d+$/ )
    result['Email'].should_not be_nil
  end

  describe "the results returned from get" do
    before do
      @api.stub!(:send_request).and_return( fixture_file_read('supporter_by_limit_1.xml'))
      @result = @api.get('table' => 'supporter', 'limit' => 1).first
    end
    it "should have hash like access" do
      @result['First_Name'].should == 'test1'
    end
    it "should have method access" do
      @result.First_Name.should == 'test1'
    end
    it "should be enumerable" do
      @result.all?.should be_true
    end
  end

  describe "proxy" do
    it "specifies name of table in hash based on method called on api" do
      @api.should_receive(:get)
      @api.supporter.get
    end
    it "should call get with group" do
      group_proxy = @api.groups
      @api.should_receive(:get)
      @api.groups.get
    end
    it "should call the api save when calling supporter.save" do
      @api.should_receive(:save)
      @api.supporter.save
    end

    it "should pass along the table name to the api" do
      @api.should_receive(:get).with(hash_including(:object => 'supporter'))
      @api.supporter.get
    end
  
    it "passes along odd methods to the API for handling" do
      @api.should_receive(:hot_topic)
      @api.supporter.hot_topic("Flex")
    end

    it "responds to columns and returns the correct number" do
      @api.stub!(:send_request).and_return(fixture_file_read('supporter_description.xml'))
      @api.supporter.columns.size.should == 56
    end

    it "counts the records in the table" do
      @api.stub!(:send_request).and_return(fixture_file_read('supporter_count.xml'))
      @api.supporter.count.should == 10
    end
  end

  describe "count method" do
    it "counts the records in the table" do
      @api.stub!(:send_request).and_return(fixture_file_read('supporter_count.xml'))
      @api.count(:object => 'supporter').should == 10
    end
    it "forwards the options to the get method" do
      start_args = { :object => 'supporter' }
      @api.should_receive(:send_request).with( @api.urls[:count], hash_including( start_args )).and_return( fixture_file_read('supporter_count.xml'))
      @api.supporter.count
    end
  end

  describe "columns method" do
    it "should return a description of the given table" do
      @api.stub!(:send_request).and_return(fixture_file_read('supporter_description.xml'))
      @api.columns(:object => 'supporter').size.should == 56
    end
  end
end
