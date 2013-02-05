require File.dirname(__FILE__) + '/../spec_helper.rb'

describe EventCustomAttribute do 
  before do
    Site.current = new_site(:id => 1)
    Site.stub!(:current_config_path).and_return(Rails.root.join('test', 'config'))

    # mock geocoder
    @geo = stub('geo', [:coordinates => [77.7777, -111.1111], :precision => "ROOFTOP"])

    Geocoder.stub!(:search).and_return(@geo)

    # mock democracy in action api
    @dia_api = stub('dia_api', :save => true, :authenticate => true)
    DemocracyInActionEvent.stub!(:api).and_return(@dia_api)
    
    @event = new_event
    @event.stub!(:set_district).and_return(true)
  end

  describe 'Event#custom_attributes_data' do
    it 'events should be able to create custom_attributes' do
      event = new_event(:custom_attributes_data => {:union=>'SEIU',:local=>'1021'})
      event.custom_attributes.length.should == 2
      event.custom_attributes_data.union.should == 'SEIU'
      event.custom_attributes_data.local.should == '1021'
    end

    it 'events should update existing custom attributes' do
      event = new_event(:custom_attributes_data => {:union=>'SEIU',:local=>'1021'})
      event.save
      event.custom_attributes_data = {:union=>'AFSME',:manager=>'Johnny Depp', :worker=>'Kate Moss'}
      event.save
      event.reload
      event.custom_attributes.length.should == 4 
      event.custom_attributes_data.union.should == 'AFSME'
    end
  end
end
