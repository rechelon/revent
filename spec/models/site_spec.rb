require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Site do
  
  describe "site.host" do
    it "should return first host if Host.current is not set" do
      Object.send(:remove_const, 'Host')
      load RAILS_ROOT+'/app/models/host.rb'
      @site = Site.new 
      @site.hosts << Host.new(:hostname => 'example.com')
      @site.hosts << Host.new(:hostname => 'foo.com')
      @site.host.hostname.should == 'example.com'
    end
  end

  describe "hosts" do
    before do
      @site = create :site
      @site.hosts << create(:host)
      Site.stub!(:current).and_return(@site)
      Host.current = 'localhost'
    end

    it "returns a host" do
      @site.host.hostname.should_not be_empty
    end

    it "can assign a new host" do
      @site.host= 'example.com'
      @site.host.hostname.should match /example.com/
    end

    it "should obey Host.current above all else" do
      @site.host= 'example.com'
      Host.current= 'test.example.com'
      @site.host.hostname.should match /test.example.com/
    end

    describe "multiple sites with multiple hosts" do
      before do
        @site.hosts << create(:host)
        @site2 = create :site 
        @site2.hosts << create(:host) 
        @site2.hosts << create(:host) 
      end
      it "should give us the right site for the host" do
        pending
        Host.current = @site.hosts.last.hostname
        Host.find_by_hostname(Host.current).site_id.should be(@site.id)
      end
    end
  end

  describe "when destroyed" do
    before do
      @site = create :site
      @site_config_id = @site.config.id
      @site.destroy
    end
    it "should destroy the associated config" do
      SiteConfig.find_by_id(@site_config_id).should be(nil)
    end
  end

end
