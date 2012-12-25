require File.dirname(__FILE__) + '/../spec_helper.rb'

describe ReportsController do
  describe 'create' do
    before do
      initialize_site
      @report = build :report
      Report.stub!(:new).and_return(@report)
      @uploaded_data = test_uploaded_file
      @create_params = {
        :report => {
          :text => "text",
          :attendees => '100',
          :event => create(:event),
          :press_link_data => {'1' => {:url => 'http://example.com', :text => 'the example site'}, '2' => {:url => 'http://other.example.com', :text => 'another one'}},
          :attachment_data => {'1' => {:caption => 'attachment 0', :uploaded_data => @uploaded_data}},
          :embed_data => {'1' => {:html => "<tag>", :caption => "yay"}, '2' => {:html => "<html>", :caption => "whoopee"}}
        },
        :user => {:first_name => "hannah", :last_name => "barbara", :email => "hannah@example.com"}
      }
    end
    
    def act!
      post :create, @create_params
    end

    it "should queue the report to be processed later if delay flag is set" do
      Site.current.config.delay_dia_sync = true
      ShortLine.stub!(:queue).and_return(true)
      @report.should_receive(:enqueue_background_processes)
      @report.should_not_receive(:background_processes)
      act!
    end

    it "should process the report immediately if delay flag is not set" do
      Site.current.config.delay_dia_sync = false
      @report.should_receive(:background_processes)
      @report.should_not_receive(:enqueue_background_processes)
      act!
    end

    it "should call after-save hooks for report" do
      @report.should_receive(:sync_unless_deferred).at_least(1).times
      act!
    end
  end
end
