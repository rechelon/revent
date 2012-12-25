require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Theme do
  before do
    @theme = create :theme
  end

  describe "should parse the body" do
    before do
      create :theme_element, :name => "body", :markdown => "testing one two{{content}} three", :theme => @theme
    end

    it "into pre_content" do
      @theme.pre_content.should == "testing one two"
    end
    
    it "into post_content" do
      @theme.post_content.should == " three"
    end
  end

  it "should respond to theme.element and theme.element=" do
    Theme::THEME_ELEMENT_NAMES.each do |e|
      @theme.should respond_to(e)
      @theme.should respond_to(e+'=')
    end
  end
end
