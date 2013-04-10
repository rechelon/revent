require File.dirname(__FILE__) + '/../spec_helper.rb'

describe AccountController do
  before do
    initialize_site
  end

  it "should redirect for facebook oauth request" do
    get :oauth_request, :provider => "facebook"
    response.should be_redirect
  end
end
