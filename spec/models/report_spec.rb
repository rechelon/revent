require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Report do
  before do
    initialize_site
    Site.current.stub!(:salesforce_enabled?).and_return(false)
    @event = create :event, :calendar => @calendar, :country_code => 'GBR'
    Akismet.stub!(:new).and_return(stub(Akismet, :comment_check => true, :last_response => true))
  end

  describe "when created" do 
    it "processes report" do
      @report = create :report, :event => @event, :user => create(:user)
      @report.should_receive :build_press_links
      @report.should_receive :build_embeds
      #@report.should_receive :send_attachments_to_flickr
      @report.should_receive :"save!"
      @report.process!
    end

    describe "user" do
      before do
        @user = create :user, :first_name => 'foxy', :email => 'test@example.com', :site => @site
      end

      it "should update if user exists" do
        @report = build :report, :event => @event 
        @report.reporter_data = {:first_name => 'testy', :last_name => 'mctest', :email => 'test@example.com'}
        @report.save!
        User.find(@user.id).first_name.should == 'testy'
      end

      it "should set the report user to the existing user" do
        @report = build :report, :event => @event, :user => nil
        @report.reporter_data = {:first_name => 'testy', :last_name => 'mctest', :email => 'test@example.com'}
        @report.save!
        @report.process!
        @report.reload.user_id.should == @user.id
      end

      it "should set the user on create" do
        @report = Report.create(:event => @event, :reporter_data => {:first_name => 'testy', :last_name => 'mctest', :email => 'test@example.com'})
        @report.user_id.should == @user.id
      end

      it "should create new users" do
        @report = build :report, :event => @event
        @report.reporter_data = {:first_name => 'testy', :last_name => 'mctest', :email => 'new@example.com'}
        @report.save!
        User.find(:first, :conditions => { :email => 'new@example.com', :site_id => @event.calendar.site.id }).should == @report.user
      end

      it "should assign new users a random password" do
        @report = build :report
        @report.reporter_data = {:first_name => 'testy', :last_name => 'mctest', :email => 'newpassword@example.com'}
        @report.save
        @report.user.crypted_password.should_not be_nil
      end
    end

    describe "press links" do
      before do
        @press_params  = {'1' => {:url => 'http://example.com', :text => 'the example site'}, '2' => {:url => 'http://other.example.com', :text => 'another one'}}
        @report = create :report, :press_link_data => @press_params
        @report.process!
      end
      it "should create press links" do
        @report.press_links(true).collect {|link| link.url}.should include('http://example.com')
      end
      it "should create correct data" do
        @report.press_links.first.text.should == 'the example site'
      end
     end

    describe "attachment" do
      before do
        @uploaded_data = test_uploaded_file
      end
      it "should create attachments" do
        @report = create :report, :attachment_data => {'1' => {:caption => 'attachment 1', :uploaded_data => @uploaded_data}}
        @report.process!
        File.exist?(@report.attachments(true).first.full_filename).should be_true
      end
      it "should create multiple attachments" do
        @report = build :report, :attachment_data => {'1' => {:caption => 'attachment 1', :uploaded_data => test_uploaded_file}, '2' => {:caption => 'attachment 2', :uploaded_data => test_uploaded_file}}
        @report.make_local_copies!
        @report.move_to_temp_files!
        @report.save
        @report.process!
        @report.attachments(true).all? {|a| File.exist?(a.full_filename)}.should be_true
      end
      it "should tag attachments" do
        pending 'tagging not high priority now; get this working later'
        @report = create :report, :attachment_data => {'1' => {:caption => 'attachment 1', :uploaded_data => @uploaded_data, :tag_depot => {'0' => 'tag1', '1' => 'tag2'}  }}
        @report.process!
        @report.attachments.tags.should_not be_empty
      end
    end

    it "should validate all associated models" do
      lambda {create(:report, :press_link_data => {'1' => {:url => '#++ &&^ %%$', :text => 'invalid url'}}).process!}.should raise_error(ActiveRecord::RecordInvalid)
    end

    describe "embeds" do
      before do
        @report = build :report
      end
      it "should accept embed data" do
        @report.embed_data = "blah"
        @report.embed_data.should == "blah"
      end
      it "should build embeds immediately when not delayed" do
        Site.current = create :site
        Site.current.config.delay_dia_sync = false
        @report.should_receive(:build_embeds).and_return(true)
        @report.sync_unless_deferred
      end
      it "should delay building embeds when delayed" do
        Site.current = create :site
        Site.current.config.delay_dia_sync = true
        ShortLine.stub!(:queue).and_return true
        @report.should_not_receive(:build_embeds)
        @report.save
        @report.sync_unless_deferred
      end
      it "should accept the standard params hash coming form" do
        @report.embed_data = {'1' => {:html => "<tag>", :caption => "yay"}, '2' => {:html => "<html>", :caption => "whoopee"}}
        @report.build_embeds
        @report.embeds.first.html.should == "<tag>"
      end
    end
    
    describe "build from hash" do
      describe "params hash with no attachments, embed, or press links" do
        before do
          @uploaded_data = test_uploaded_file
          @params = {:report => {:text => "text", :attendees => '100', :event => create(:event),
                    :reporter_data => {:first_name => "hannah", :last_name => "barbara", :email => "hannah@example.com"},
                    :press_link_data => {'1' => {:url => '', :text => ''}, '2' => {:url => '', :text => ''}},
                    :attachment_data => {'1' => {:caption => '', :uploaded_data => nil }},
                    :embed_data => {'1' => {:html => "", :caption => ""}, '2' => {:html => "", :caption => ""}}}}
          @report = Report.create!(@params[:report].merge( :akismet_params => stub('request_object').as_null_object))
        end
        it "should not create attachments when no attachment data is provided" do
          @report.attachments.should be_empty
        end
        it "should not create embeds when no embed data is provided" do
          @report.embeds.should be_empty
        end
        it "should not create press links when no press link data is provided" do
          @report.press_links.should be_empty
        end
      end
      describe "full params hash" do
        before do
          @uploaded_data = test_uploaded_file
          @params = {:report => {:text => "text", :attendees => '100', :event => create(:event),
                    :reporter_data => {:first_name => "hannah", :last_name => "barbara", :email => "hannah@example.com"},
                    :press_link_data => {'1' => {:url => 'http://example.com', :text => 'the example site'}, '2' => {:url => 'http://other.example.com', :text => 'another one'}},
                    :attachment_data => {'1' => {:caption => 'attachment 1', :uploaded_data => @uploaded_data}},
                    :embed_data => {'1' => {:html => "<tag>", :caption => "yay"}, '2' => {:html => "<html>", :caption => "whoopee"}}
                  }}
          @report = Report.create!(@params[:report].merge( :akismet_params => stub('request_object').as_null_object))
          @report.process!
        end
        it "gets text" do
          @report.text.should == 'text'
        end
        it "saves successfully" do
          @report.id.should_not be_nil
        end
        it "should copy reporter data to user" do 
          @report.user.first_name.should == "hannah"
        end
        it "should create user" do 
          @report.user.id.should_not be_nil
        end
        it "should copy attachment data" do 
          @report.should_receive(:attachment_data=)
          @report.update_attributes(@params[:report])
        end
        it "should copy attachment data to attachment" do 
          @report.attachments.first.caption.should == "attachment 1"
        end
        it "should create attachment" do 
          @report.attachments.first.id.should_not be_nil
        end
        it "should create press links" do
          @report.press_links.first.url.should match(/example/)
        end
        it "should save said press links" do
          @report.press_links.first.id.should_not be_nil
        end
        it "should save embeds" do
          @report.embeds.first.id.should_not be_nil
        end
        it "should create embeds" do
          @report.embeds.first.html.should match(/tag/)
        end
      end
    end

    describe "upload attachments to flickr" do
      before do
        @upload_proxy = stub( 'uploads_proxy', :upload_image => true )
        @photo_proxy  = stub( 'photos_proxy', :upload => @upload_proxy )
        @photoset_proxy = stub( 'photoset_proxy', :addPhoto => true )
        @flickr_api = stub( 'flickr_api', :photos => @photo_proxy, :photosets => @photoset_proxy )
        Site.stub!(:flickr).and_return( @flickr_api )
        @attach = create :attachment, :primary => true, :temp_data => 'data data data'
        @report = create :report, :event => @event
        @report.attachments << @attach
        @report.status = Report::PUBLISHED
      end
      it "does not work without a valid Flickr connection" do
        pending 
        @upload_proxy.should_not_receive(:upload_image)
        Site.stub!(:flickr).and_return(false)
        @report.send_attachments_to_flickr
      end
      it "should not send unpublished items to flickr" do
        pending 
        @report.stub!(:published?).and_return(false)
        @upload_proxy.should_not_receive(:upload_image)
        @report.send_attachments_to_flickr
      end
      it "should not send items that already have been uploaded"  do
        pending 
        @report.attachments.first.flickr_id = "123"
        @upload_proxy.should_not_receive(:upload_image)
        @report.send_attachments_to_flickr
      end
      it "checks for metadata" do
        pending 
        @report.should_receive(:flickr_title)
        @report.send_attachments_to_flickr
      end
      it "works from tempfiles or full files" do
        pending 
        @attach.should_receive(:temp_data).and_return( false )
        @report.send_attachments_to_flickr
      end
      it "calls upload on the flickr api" do
        pending 
        @upload_proxy.should_receive(:upload_image)
        @report.send_attachments_to_flickr
      end
      it "sets the flickr id attribute" do
        pending 
        @upload_proxy.stub!(:upload_image).and_return(5)
        @attach.should_receive(:flickr_id=).with(5)
        @report.send_attachments_to_flickr
      end
      it "does not save if the flickr upload failed" do
        pending 
        @upload_proxy.stub!(:upload_image).and_return false 
        @attach.should_not_receive(:save)
        @report.send_attachments_to_flickr
      end
      it "adds the photoset if the attachment is primary and the photoset is defined" do
        pending 
        @upload_proxy.stub!(:upload_image).and_return('998988978')
        @photoset_proxy.should_receive(:addPhoto)
        @report.send_attachments_to_flickr
      end
      it "does not add the photoset if no photoset is defined" do
        pending 
        @calendar.stub!(:flickr_photoset).and_return(nil)
        @photoset_proxy.should_not_receive(:addPhoto)
        @report.send_attachments_to_flickr
      end
      it "does not add the photoset if the attachment is not primary" do
        pending 
        @calendar.stub!(:flickr_photoset).and_return( 5 )
        @report.attachments.first.primary = false
        @photoset_proxy.should_not_receive(:addPhoto)
        @report.send_attachments_to_flickr
      end
      it "rescues XMLRPC errors" do
        pending 
        @flickr_api.stub!(:photos).and_raise( XMLRPC::FaultException.new( "problem", "yeah" ) )
        lambda{ @report.send_attachments_to_flickr }.should_not raise_error
      end
    end

    describe 'email trigger' do
      it "delivers a trigger if the calendar has no triggers but the site does" do
        TriggerMailer.should_receive(:deliver_trigger)
        @site.stub!(:triggers).and_return(stub('triggers', :any? => true, :find_by_name => true ))
        @report = build :report, :event => @event
        @report.trigger_email
      end
    end

  end #when created

  describe "when updated" do
  end

  describe "when destroyed" do
  end

end
