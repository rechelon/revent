require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Supporter do 
  before do
    initialize_site
    
    @sf_supporter_1 = create :supporter
    @sf_supporter_2 = create :supporter, 
                        :first_name=>'David',
                        :last_name=>'Taylor',
                        :email=>'radcowpenliz+sf_supporter_2@gmail.com',
                        :street=>'3150 24th st',
                        :postal_code => '94110' 

    @ny_supporter_1 = create :supporter, 
                        :first_name=>'Jane',
                        :last_name=>'Doe',
                        :email=>'radcowpenliz+ny_supporter_1@gmail.com',
                        :street=>'11 Wall St #7',
                        :city=>'New York',
                        :state=>'NY',
                        :postal_code => '10005'

    @ny_supporter_2 = create :supporter, 
                        :first_name=>'Joe',
                        :last_name=>'Stiglitz',
                        :email=>'radcowpenliz+ny_supporter_2@gmail.com',
                        :street=>'50 Wall St ',
                        :city=>'New York',
                        :state=>'NY',
                        :postal_code=> '10005'

  end

  describe 'on creation' do
    it 'should geocode supporters' do
       truncate_float(@sf_supporter_1.latitude, 2).should == 37.77
       truncate_float(@sf_supporter_1.longitude, 2).should == -122.42
       truncate_float(@ny_supporter_1.latitude, 2).should == 40.70
       truncate_float(@ny_supporter_1.longitude, 2).should ==  -74.02
    end
  end
  describe 'near_event' do
    it 'should return only sf supporters when searching for event with postal_code 94114' do
      event = create :event, :location=>'1 Market st', :city=>'San Francisco', :state=>'CA', :postal_code=>'94114'
      supporters = Supporter.near_event(event)
      supporters.size.should == 2
      supporters.should_not include([@ny_supporter_1, @ny_supporter_2])
    end
  end
  describe 'getting supporters from DIA group' do
    it 'should build a supporter from a dia record' do
      dia_record = {"City"=>"San Francisco", "Receive_Email"=>"1", "Last_Modified"=>"2010-08-05 21:07:47.0", "Zip"=>"94114", "Date_Created"=>"2010-08-05 21:07:46.0", "PRIVATE_Zip_Plus_4"=>"0000", "Phone"=>"555-555-5555", "Source"=>"Web", "Source_Tracking_Code"=>"(No Original Source Available)", "State"=>"CA", "Email"=>"jon.vpdwpwes@stepitup.org", "Street"=>"1370 Mission St.", "Source_Details"=>"(No Referring info)", "First_Name"=>"Jon", "organization_KEY"=>"962", "Last_Name"=>"Warnow", "key"=>"42854626", "supporter_KEY"=>"42854626"}
      supporter = Supporter.build_from_dia_record( dia_record)
      supporter.dia_supporter_id.should == "42854626"
      supporter.postal_code.should == "94114"
    end

    it 'should add a group and not duplicate group keys' do
      @sf_supporter_1.add_group_key('1')
      @sf_supporter_1.add_group_key('2')
      @sf_supporter_1.add_group_key('1')
      @sf_supporter_1.dia_group_keys.should == '1,2'
    end

    it 'should create new supporters' do
      Supporter.create_supporters_from_dia_group('78640')
      Supporter.find_all_by_email('radcowpenliz+some@gmail.com').size.should == 1
      Supporter.find_all_by_email('radcowpenliz+somebody@gmail.com').size.should == 1
    end

    it 'should not crete duplicate supporters' do
      Supporter.create_supporters_from_dia_group('78640')
      Supporter.create_supporters_from_dia_group('78640')
      Supporter.find_all_by_email('radcowpenliz+some@gmail.com').size.should == 1
      Supporter.find_all_by_email('radcowpenliz+somebody@gmail.com').size.should == 1
    end
  end
end
