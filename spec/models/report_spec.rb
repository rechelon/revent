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
        @report = create :report, :attachment_data => {'1' => {:caption => 'attachment 1', :filename => @uploaded_data}}
        @report.process!
        File.exist?(@report.attachments.first.filename.path).should be_true
      end
      it "should create multiple attachments" do
        @report = build :report, :attachment_data => {'1' => {:caption => 'attachment 1', :filename => @uploaded_data}, '2' => {:caption => 'attachment 2', :filename => @uploaded_data}}
        @report.save
        @report.process!
        @report.attachments(true).all? {|a| File.exist?(a.filename.path)}.should be_true
      end
      it "should tag attachments" do
        pending 'tagging not high priority now; get this working later'
        @report = create :report, :attachment_data => {'1' => {:caption => 'attachment 1', :filename => @uploaded_data, :tag_depot => {'0' => 'tag1', '1' => 'tag2'}  }}
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
                    :attachment_data => {'1' => {:caption => '', :filename => nil }},
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
                    :attachment_data => {'1' => {:caption => 'attachment 1', :filename => @uploaded_data}},
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

    describe "upload attachments to remote storage engine (amazon s3)" do
      if $test_aws
        require 'typhoeus'
        before do
          @original_storage_type = AttachmentUploader::storage_type
          AttachmentUploader::storage_type = :fog
          CarrierWave.configure do |config|
            config.fog_credentials = $test_fog[:credentials]
            config.fog_directory = $test_fog[:directory]
            config.fog_force_path_for_aws = $test_fog[:force_path_for_aws]
          end
          @uploaded_data = test_uploaded_file
          @params = {:report => {:text => "text", :attendees => '100', :event => create(:event),
                    :reporter_data => {:first_name => "hannah", :last_name => "barbara", :email => "hannah@example.com"},
                    :press_link_data => {'1' => {:url => 'http://example.com', :text => 'the example site'}, '2' => {:url => 'http://other.example.com', :text => 'another one'}},
                    :attachment_data => {'1' => {:caption => 'attachment 1', :filename => @uploaded_data}},
                    :embed_data => {'1' => {:html => "<tag>", :caption => "yay"}, '2' => {:html => "<html>", :caption => "whoopee"}}
                  }}
          @report = Report.create!(@params[:report].merge( :akismet_params => stub('request_object').as_null_object))
          @report.process!
        end
        it "should upload file to s3" do
          Typhoeus::Request.get(@report.attachments.first.filename.url).code.should == 200
        end
        it "should upload thumbnail (list) to s3" do
          Typhoeus::Request.get(@report.attachments.first.filename.thumbnail.list.url).code.should == 200
        end
        it "should upload thumbnail (pageview) to s3" do
          Typhoeus::Request.get(@report.attachments.first.filename.thumbnail.pageview.url).code.should == 200
        end
        it "should upload thumbnail (lightbox) to s3" do
          Typhoeus::Request.get(@report.attachments.first.filename.thumbnail.lightbox.url).code.should == 200
        end
        after do
          AttachmentUploader::storage_type = @original_storage_type
        end
      end
    end

    describe 'email trigger' do
      it "delivers a trigger if the calendar has no triggers but the site does" do
        @site.stub!(:triggers).and_return(stub('triggers', :any? => true, :find_by_name => true ))
        t = stub('trigger')
        t.should_receive(:deliver)
        TriggerMailer.stub(:trigger).and_return(t)
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
