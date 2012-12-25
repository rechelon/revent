require File.dirname(__FILE__) + '/../spec_helper.rb'

describe EventsController do
  before do
    initialize_site
    controller.stub!(:clean)
  end

  it "should set site from host" do
    get :index
    @controller.site.host.should == @site.host
  end

  it "should redirect on index if no query" do
    get :index
    response.should be_redirect
  end

  describe "show" do
    before do
      @event = build :event
      @calendar.stub!(:events).and_return(stub('events', :find => @event))
      get :show, :id => 111
    end
    it "should be success" do
      response.should be_success
    end
    it "should use show template" do
      response.should render_template('show')
    end
    it "should assign event" do
      assigns[:event].should == @event
    end
  end
  describe "new" do
    before do
      get :new, :calendar_id => 1
    end
    it "should be success" do
      response.should be_success
    end
    it "should use show template" do
      response.should render_template('new')
    end
    it "should assign event" do
      assigns[:event].should_not be_nil
    end
  end
  describe "create" do
    describe "with new user" do
      before do
        @user = build :user, :email => 'newemail@example.com'
        @user.stub!(:save!)
        @user.stub!(:valid?).and_return(true)
        User.stub!(:find_or_build_related_user).and_return @user
        @event = build :event
        @event.id = 1
        @event.stub!(:save!)
        @event.stub!(:valid?).and_return(true)
        @calendar.stub!(:events).and_return(stub('event', :build => @event))
      end
      def act!(user=nil)
        post :create, :permalink => @calendar.permalink
      end
      it "should redirect" do
        act!
        response.should be_redirect
      end
      it "should redirect to show" do
        act!
        response.should redirect_to(:host => @site.host.hostname, :permalink => @calendar.permalink, :action => 'show', :id => 1)
      end
    end
  end
  describe "rsvp" do
    before do
      @event = create :event, :calendar => @calendar
    end

    describe "with unused email" do
      before do
        post :rsvp, :id => @event.id, :permalink => @calendar.permalink,
          :user => {
            :email => 'testing12345@example.com',
            :first_name => 'testy',
            :last_name => 'mctesterson',
            :phone => '555-555-5555',
            :postal_code => '12345'
          }
      end
      def get_user
        User.find_by_email_and_site_id('testing12345@example.com', Site.current.id)
      end
      it "should create user" do
        get_user.should_not == nil
      end
      it "should add created user to attendees" do
        @event.attendees.first.should == get_user
      end
    end

    describe "with used email" do
      before do
        @user = create :user,
          :email => 'established_user@example.com',
          :first_name => 'established',
          :last_name => '',
          :site => Site.current
        post :rsvp, :id => @event.id, :permalink => @calendar.permalink,
          :user => {
            :email => 'established_user@example.com',
            :first_name => 'spammy',
            :last_name => 'user'
          }
     end
      def get_user
        User.first(:conditions => {
          :email => 'established_user@example.com',
          :first_name => 'established',
          :last_name => 'user'
        })
      end
      it "should update blank user fields" do
        get_user.should_not == nil 
      end
      it "should add updated user to attendees" do
        @event.attendees.first.should == get_user
      end
    end

    describe "with logged in user" do
      before do
        @user = create :user
        session[:user] = @user.id
        post :rsvp, :id => @event.id, :permalink => @calendar.permalink, :user => {}
      end
      it "should add user to attendees" do
        @event.attendees.first.should == @user
      end
    end
  end

  it "shows recently added" do
    get 'recently_added', :format => 'xml'
    response.should be_success
  end
  it "shows recently upcoming" do
    get 'upcoming', :format => 'xml'
    response.should be_success
  end
end
