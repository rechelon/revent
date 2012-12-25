require File.dirname(__FILE__) + '/../../spec_helper'

describe Varnish::ThemeElementSweeper do
  before do
    Site.stub!(:current).and_return(build :site)
    Host.stub!(:current).and_return(build :host)
    Site.current.hosts << Host.current
    @theme = create :theme
    @calendar_one = create :calendar, :permalink => "one", :theme_id => @theme.id
    @calendar_two = create :calendar, :permalink => "two", :theme_id => @theme.id
  end

  describe "when a theme element is created" do
    it "should determine the correct purge routes" do
      Varnish::ThemeElementSweeper.instance.should_receive(:purges).with(['one','two']).and_return([])
      Varnish::ThemeElementSweeper.instance.should_receive(:bans).with(['one/','two/']).and_return([])
      create :theme_element, :theme => @theme
    end
    it "should call the purging method" do
      Varnish::ThemeElementSweeper.instance.should_receive(:hydra_run_requests)
      create :theme_element, :theme => @theme
    end
  end

  describe "when an event" do
    before do
      @theme_element = create :theme_element, :theme => @theme
    end
    
    describe "is updated" do
      it "should determine the correct purge routes" do
        Varnish::ThemeElementSweeper.instance.should_receive(:purges).with(['one','two']).and_return([])
        Varnish::ThemeElementSweeper.instance.should_receive(:bans).with(['one/','two/']).and_return([])
        @theme_element.markdown = "something else"
        @theme_element.save
      end
      it "should call the purging method" do
        Varnish::ThemeElementSweeper.instance.should_receive(:hydra_run_requests)
        @theme_element.markdown = "Some new html"
        @theme_element.save
      end
    end

    describe "is destroyed" do
      it "should determine the correct purge routes" do
        Varnish::ThemeElementSweeper.instance.should_receive(:purges).with(['one','two']).and_return([])
        Varnish::ThemeElementSweeper.instance.should_receive(:bans).with(['one/','two/']).and_return([])
        @theme_element.destroy
      end
      it "should call the purging method" do
        Varnish::ThemeElementSweeper.instance.should_receive(:hydra_run_requests)
        @theme_element.destroy
      end
    end
  end
end
