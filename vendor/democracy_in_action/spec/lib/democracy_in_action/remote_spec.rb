if !ENV['REMOTE']
  puts "not running remote specs, set ENV['REMOTE']"
else

require File.dirname(__FILE__) + "/../../spec_helper"
require 'httpclient'

NODE    = 'https://sandbox.salsalabs.com'
EMAIL = 'demo'
PASS = 'demo'

describe "DemocracyInAction API" do

  authentication_url = NODE + '/api/authenticate.sjs'
  describe "authentication requests (POST #{authentication_url})" do
    before do
      @client = HTTPClient.new
    end
    describe "with invalid credentials (invalid email and password)" do
      before do
        @r ||= @client.post(authentication_url,"email=dummy&password=sekrit")
        @response = @r.dup
      end
      it "should have 200 status, even tho we might prefer something in the 400s" do
        @response.status.should == 200
      end
      it "should have an error message in the body" do
        @response.content.should match(/Invalid login/)
      end
      it "should match the invalid_auth fixture" do
        @response.content.should == fixture_file_read('invalid_auth.xml')
      end
    end
    describe "with valid credentials (valid email and password)" do
      before do
        @r ||= @client.post(authentication_url,"email=#{EMAIL}&password=#{PASS}")
        @response = @r.dup
      end
      it "should have 200 status" do
        @response.status.should == 200
      end
      it "should have show success message" do
        @response.content.should =~ /Successful Login/
      end
      it "should match the valid_auth fixture" do
        @response.content.should == fixture_file_read('valid_auth.xml')
      end
    end
  end

  describe "request for" do
    before do
      @unauthed_client   ||= HTTPClient.new
      @unauthed_response ||= @unauthed_client.post(authentication_url,"email=dummy&password=sekrit")
      @authed_client     ||= HTTPClient.new
      @authed_response   ||= @authed_client.post(authentication_url,"email=#{EMAIL}&password=#{PASS}")
    end

    count_url = NODE + "/api/getCount.sjs?object=supporter"
    describe "count (GET #{count_url})" do
      describe "when not authenticated" do
        before do
          @unauthed_count_response ||= @unauthed_client.get(count_url)
          @response = @unauthed_count_response.dup
        end
        it "should have error message" do
          @response.body.content.should =~ /<data organization_KEY="-1">/
        end
        it "should match invalid supporter count fixture" do
          @response.body.content.should == fixture_file_read('invalid_supporter_count.xml')
        end
      end
      describe "when authenticated" do
        before do
          @authed_count_response ||= @authed_client.get(count_url)
          @response = @authed_count_response.dup
        end
        it "should have a success message" do
          @response.body.content.should =~ /<data organization_KEY="\d+">/
        end
        it "should match supporter count fixture" do
          @response.body.content.should have_the_same_xml_structure_as(fixture_file_read('supporter_count.xml'))
        end
      end
    end

    counts_url = NODE + "/api/getCounts.sjs?object=supporter&groupBy=Email"
    describe "grouped count (GET #{counts_url})" do
      describe "when not authenticated" do
        before do
          @unauthed_counts_response ||= @unauthed_client.get(counts_url)
          @response = @unauthed_counts_response.dup
        end
        it "should have error message" do
          @response.body.content.should =~ /<data organization_KEY="-1">/
        end
      end
      describe "when authenticated" do
        before do
          @authed_counts_response ||= @authed_client.get(counts_url)
          @response = @authed_counts_response.dup
        end
        it "should have a success message" do
          @response.body.content.should =~ /<data organization_KEY="\d+">/
        end
        it "should have the same structure as getCounts fixture" do
          @response.body.content.should have_the_same_xml_structure_as(fixture_file_read('getCounts.sjs.xml'))
        end
      end
    end

    objects_url = NODE + "/api/getObjects.sjs?object=supporter&limit=0"
    describe "multiple objects (GET #{objects_url})" do
      describe "when not authenticated" do
        before do
          @unauthed_object_response ||= @unauthed_client.get(objects_url)
          @response = @unauthed_object_response.dup
        end
        it "should have organization_KEY == -1" do
          @response.body.content.should =~ /<data organization_KEY="-1">/
        end
      end
      describe "when authenticated" do
        before do
          @authed_object_response ||= @authed_client.get(objects_url)
          @response = @authed_object_response.dup
        end
        it "should have organization_KEY == your organization key" do
          @response.body.content.should =~ /<data organization_KEY="\d+">/
        end
        it "should have the same structure as supporters fixture" do
        end
      end
    end

    object_url = NODE + "/api/getObject.sjs?object=supporter&key=<key>"
    describe "single object (GET #{object_url})" do
      describe "when not authenticated" do
        before do
          @unauthed_object_response ||= @unauthed_client.get(object_url.gsub('<key>','-1'))
          @response = @unauthed_object_response.dup
        end
        it "should have organization_KEY undefined" do
          @response.body.content.should =~ /<data organization_KEY="undefined">/
        end
      end
      describe "when authenticated, but we don't have access" do
        before do
          @authed_object_response ||= @authed_client.get(object_url.gsub('<key>','-1'))
          @response = @authed_object_response.dup
        end
        it "should have organization_KEY undefined, which is unfortunately the same response as unauthenticated" do
          @response.body.content.should =~ /<data organization_KEY="undefined">/
        end
      end
      describe "when authenticated" do
        before do
          @r ||= @authed_client.get(objects_url.gsub('limit=0','limit=1'))
          key = @r.body.content[/<supporter_KEY>(\d+)<\/supporter_KEY>/,1]
          @authed_object_response ||= @authed_client.get(object_url.gsub('<key>',"#{key}"))
          @response = @authed_object_response.dup
        end
        it "should have the same structure as supporter fixture" do
          @response.body.content.should have_the_same_xml_structure_as(fixture_file_read('supporter_by_key.xml'))
        end
      end
    end

    save_url = NODE + "/save?xml&object=supporter&Email=test@example.com"
    describe "save (GET #{save_url})" do
      describe "when not authenticated" do
        before do
          @unauthed_save_response ||= @unauthed_client.get(save_url)
          @response = @unauthed_save_response.dup
        end
        it "should have error message" do
          @response.body.content.should =~ /<error object="supporter"/ 
        end
      end
      describe "when authenticated" do
        before do
          @authed_save_response ||= @authed_client.get(save_url)
          @response = @authed_save_response.dup
        end
        it "should have a success message" do
          @response.body.content.should =~ /<success object="supporter"/ 
        end
      end
    end

    delete_url = NODE + "/delete?object=supporter&xml=1&key="
    describe "delete (GET #{delete_url}<key>)" do
      before do
        @authed_save_response ||= @authed_client.get(save_url)
        @key = @authed_save_response.body.content[/key="(\d+)"/,1]
      end
      describe "when not authenticated" do
        before do
          @unauthed_delete_response ||= @unauthed_client.get(delete_url+@key)
          @response = @unauthed_delete_response.dup
        end
        it "should have error message" do
          @response.body.content.should match(/error table="supporter/ )
        end
      end
      describe "when authenticated" do
        before do
          @authed_delete_response ||= @authed_client.get(delete_url+@key)
          @response = @authed_delete_response.dup
        end
        it "should have a success message" do
          @response.body.content.should match( /<success table="supporter/ )
        end
      end
    end

    email_url = NODE + "/email?xml&to=to@example.com&from=from@example.com&subject=test&content=test"
    describe "email (GET #{email_url})" do
      before do 
        @success =%r{<br/>Testing\ for\ spam:\ false}
        @spam_response = %r|<br/>Testing for spam: falseThanks!  Your message has been sent.|
      end
      describe "when not authenticated" do
        before do
          @unauthed_email_response ||= @unauthed_client.get(email_url)
          @response = @unauthed_email_response.dup
        end
        it "reports email is successfully sent" do
          @response.body.content.should match( @success )
        end
      end
      describe "when authenticated" do
        before do
          @authed_email_response ||= @authed_client.get(email_url)
          @response = @authed_email_response.dup
        end
        it "should have a success message" do
          @response.body.content.should match( @success )
        end
      end
      describe "content trips spam filter" do
        before do
          @authed_spam_response ||= @authed_client.get(email_url+"&content=viagra")
          @response = @authed_spam_response.dup
        end
        it "reports success and includes additional affirmation the mesg has been sent" do
          @response.body.content.should match(@spam_response)
        end
      end
    end
  end
end
end
