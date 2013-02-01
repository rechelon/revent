class AccountController < AccountControllerShared
  before_filter :login_required, :only => :profile

  def get_theme
    return Calendar.find_by_permalink(params[:permalink]).theme if params[:permalink]
    super
  end

  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
    redirect_to manage_account_path(:permalink => @calendar.permalink)
  end

  def activate
    if current_user
      flash[:notice] = "You are already logged in"
      redirect_to manage_account_path(:permalink => @calendar.permalink)
      return
    end
      
    if params[:id]
      @user = User.find_by_activation_code(params[:id]) 
      if @user and @user.activate
        self.current_user = @user
        redirect_to(:action => 'reset_password')
        flash[:notice] = "Your account has been activated." 
      else
        flash[:error] = "Unable to activate the account. If you do not remember your password, you will need to request a password reset."
        redirect_to :action => 'forgot_password'
      end
    else
      flash.clear
    end
  end

  def send_activation
#    user = DemocracyInActionSupporter.find(:first, :conditions => "Email='#{params[:email]}'")
    user = User.find_by_site_id_and_email(Site.current, params[:email]) if params[:email]
    if !user
      flash[:notice] = "Email not found"
      redirect_to login_url
      return
    end
    if user.activated_at 
      user.forgot_password
      user.save
      flash[:notice] = "Your account was already active.<br />  If you would like to reset your password, click on 'Forgot Your Password?' below" 
    else
      UserMailer.activation(user).deliver
      flash[:notice] = 'An email with an account activation link has been sent to you.'
    end
    redirect_to login_url
  end

  def rsvped
    @user = current_user
    @rsvp = Rsvp.find_by_user_id_and_event_id @user.id, params[:event_id]
    respond_to do |format|
      format.json do
        render :text => String(!@rsvp.nil?)
      end
      format.html do
        render :text => '.json and .rss formats only'
      end
      format.rss do
        render :layout => false
      end
    end
  end

  def profile
    @user = current_user
    @liquid[:profile_union_form] = render_to_string :partial => 'account/profile_union_form'
    return unless request.post?
    @user.attributes = params[:user]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.create_profile_image(params[:profile_image]) unless params[:profile_image].nil? || params[:profile_image][:uploaded_data].blank?
    if @user.save
      flash[:notice] = "Your profile has been updated"
      redirect_to manage_account_path(:permalink => @calendar.permalink)
    else
      flash[:notice] = "There was an error updating your profile"
    end
  end

=begin
  def events
    @user = current_user
    @event = Event.find(params[:id])
    if current_user.supporter_KEY != @event.dia_event.supporter_KEY
      flash[:error] = 'You can only edit events you are hosting'
      redirect_to :action => 'profile' and return
    end
  end
=end

  def login
    @permalink = params[:permalink] ? params[:permalink] : nil
    @email = params[:email]
    return unless request.post?
    self.current_user = User.authenticate(params[:email], params[:password])
    if current_user
      cookies[:revent_auth] = '1';
      if params[:remember_me] == "1" && current_user.respond_to?(:remember_me)
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if params[:redirect].nil? || params[:redirect].empty?
        redirect_to manage_account_path(:permalink => @permalink)
      else
        redirect_to params[:redirect]
      end
      flash.now[:notice] = "Logged in successfully"
    else
      flash.now[:error] = "Login failed"
    end
  end

  def login_popup
    render :layout=>false
  end

  # encodes strings that make twitter oauth happy
  def encode( string )
    URI.escape( string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

  def generate_nonce(size=7)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
  end
  
  def oauth_request
    session[:oauth_redirect_url] = params[:redirect] if params[:redirect]
    case params[:provider]
    
      when 'facebook'
        redirect_to "http://www.facebook.com/dialog/oauth?client_id=#{Host.current.fb_app_id}&redirect_uri=#{oauth_response_url(:provider=>'facebook')}&scope=email"
        return
      when 'google'
        res = oauth_token :request_url => 'https://www.google.com/accounts/OAuthGetRequestToken',
                          :oauth_key => Host.current.google_oauth_key,
                          :oauth_secret => Host.current.google_oauth_secret,
                          :oauth_callback => oauth_response_url(:provider=>'google'),
                          :scope => 'https://www.googleapis.com/auth/userinfo#email'
        if res['status'] == '200'
          session[:oauth_token] = res['oauth_token']
          session[:oauth_token_secret] = res['oauth_token_secret']
          redirect_to "https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=#{res['oauth_token']}"
          return
        end

      when 'twitter'
        res = oauth_token :request_url => 'http://api.twitter.com/oauth/request_token',
                          :oauth_key => Host.current.twitter_oauth_key,
                          :oauth_secret => Host.current.twitter_oauth_secret,
                          :oauth_callback => oauth_response_url(:provider=>'twitter')
        if res['status'] == '200'
          session[:oauth_token] = res['oauth_token']
          session[:oauth_token_secret] = res['oauth_token_secret']                         
          redirect_to "http://api.twitter.com/oauth/authenticate?oauth_token=#{res['oauth_token']}"  
          return
        end          
    end
    # oauth didn't work
    # TODO: add hoptoad notification
    flash[:error] = "#{params[:provider]} login currently unavailable"
    redirect_to login_url
  end
  
  def oauth_response 
    case params[:provider]
    
      when 'facebook'
        facebook_find_or_create_account
        return
      when 'google'
        res = oauth_token :request_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
                    :oauth_key => Host.current.google_oauth_key,
                    :oauth_secret => Host.current.google_oauth_secret,
                    :oauth_token => params[:oauth_token],
                    :oauth_token_secret => session[:oauth_token_secret],
                    :oauth_verifier => params[:oauth_verifier]                
        
        if(res['status'] == '200' && !res['oauth_token'].nil?)
          data = oauth_token2 :request_url => 'https://www.googleapis.com/userinfo/email',
                      :oauth_key => Host.current.google_oauth_key,
                      :oauth_secret => Host.current.google_oauth_secret,
                      :oauth_token => res['oauth_token'],
                      :oauth_token_secret => res['oauth_token_secret']
          if(data['status']=='200')
            if data['email']
              google_find_or_create_account data['email']
              return
            elsif data['data.email']
              google_find_or_create_account data['data.email']
              return
            end
          end
        end
      when 'twitter'
        res = oauth_token :request_url => 'https://api.twitter.com/oauth/access_token',
                    :oauth_key => Host.current.twitter_oauth_key,
                    :oauth_secret => Host.current.twitter_oauth_secret,
                    :oauth_token => params[:oauth_token],
                    :oauth_token_secret => session[:oauth_token_secret],                    
                    :oauth_verifier => params[:oauth_verifier]
        if(res['status'] == '200' && !res['user_id'].nil?)
          twitter_find_or_create_account res['user_id']
          return
        end
    end
    #didn't work
    flash[:error] = "Unable to login via #{params[:provider]}"
    redirect_to login_path
  end
  
  def oauth_token options

    @passed = nil
    @passed = {
      :oauth_consumer_key => options[:oauth_key],
      :oauth_nonce => generate_nonce,
      :oauth_signature_method => "HMAC-SHA1",
      :oauth_timestamp => Time.now.to_i.to_s,
      :oauth_version => "1.0"
    }

    @passed[:oauth_callback] = CGI::escape(options[:oauth_callback]) if options[:oauth_callback]
    @passed[:scope] = CGI::escape(options[:scope]) if options[:scope] 
    @passed[:oauth_token] = CGI::escape(options[:oauth_token]) if options[:oauth_token] 
    @passed[:oauth_verifier] = CGI::escape(options[:oauth_verifier]) if options[:oauth_verifier] 
    
    @query = ''
    @query += "oauth_callback=#{@passed[:oauth_callback]}&" if @passed[:oauth_callback]
    @query += "oauth_consumer_key=#{@passed[:oauth_consumer_key]}"
    @query += "&oauth_nonce=#{@passed[:oauth_nonce]}"
    @query += "&oauth_signature_method=#{@passed[:oauth_signature_method]}"
    @query += "&oauth_timestamp=#{@passed[:oauth_timestamp]}"
    @query += "&oauth_token=#{@passed[:oauth_token]}" if @passed[:oauth_token]
    @query += "&oauth_verifier=#{@passed[:oauth_verifier]}" if @passed[:oauth_verifier]
    @query += "&oauth_version=#{@passed[:oauth_version]}"    
    @query += "&scope=#{@passed[:scope]}" if @passed[:scope]
        
    @signature_data = "GET&#{CGI::escape(options[:request_url])}&#{CGI::escape(@query)}"
    @secret = options[:oauth_secret] + "&"
    @secret += CGI::escape(options[:oauth_token_secret]) if options[:oauth_token_secret]

    
    @signature = CGI::escape(Base64.encode64(
                  OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),@secret,@signature_data)
                 ).chomp.gsub(/\n/, ""))
    @query += "&oauth_signature=#{@signature}"

    @post_array = [];
    @post_array.push("oauth_nonce=\"#{@passed[:oauth_nonce]}\"")
    @post_array.push("oauth_callback=\"#{@passed[:oauth_callback]}\"") if @passed[:oauth_callback]
    @post_array.push("oauth_signature_method=\"#{@passed[:oauth_signature_method]}\"")
    @post_array.push("oauth_timestamp=\"#{@passed[:oauth_timestamp]}\"")
    @post_array.push("oauth_token=\"#{@passed[:oauth_token]}\"") if @passed[:oauth_token]
    @post_array.push("oauth_verifier=\"#{@passed[:oauth_verifier]}\"") if @passed[:oauth_verifier]
    @post_array.push("oauth_consumer_key=\"#{@passed[:oauth_consumer_key]}\"")
    @post_array.push("oauth_signature=\"#{@signature}\"")
    @post_array.push("oauth_version=\"#{@passed[:oauth_version]}\"")
    @post_array.push("scope=\"#{@passed[:scope]}\"") if @passed[:scope]
    
    @post_string = @post_array.join(", ")
  
    res = `curl -g -m 3 -w '&status=%{http_code}' -H 'Authorization: OAuth #{@post_string}' #{options[:request_url]}`
    return res.split('&').inject({}) do |hsh, i| kv = i.split('='); hsh[kv[0]] = kv[1]; hsh end
  end
  
  # TODO: migrate to REE and leave this ruby hellhole behind
  def oauth_token2 options
    
    @passed = nil
    @passed = {
      :oauth_consumer_key => options[:oauth_key],
      :oauth_nonce => generate_nonce,
      :oauth_signature_method => "HMAC-SHA1",
      :oauth_timestamp => Time.now.to_i.to_s,
      :oauth_version => "1.0"
    }

    @passed[:oauth_callback] = CGI::escape(options[:oauth_callback]) if options[:oauth_callback]
    @passed[:scope] = CGI::escape(options[:scope]) if options[:scope] 
    @passed[:oauth_token] = options[:oauth_token] if options[:oauth_token] 
    @passed[:oauth_verifier] = CGI::escape(options[:oauth_verifier]) if options[:oauth_verifier] 
    
    @query = ''
    @query += "oauth_callback=#{@passed[:oauth_callback]}&" if @passed[:oauth_callback]
    @query += "oauth_consumer_key=#{@passed[:oauth_consumer_key]}"
    @query += "&oauth_nonce=#{@passed[:oauth_nonce]}"
    @query += "&oauth_signature_method=#{@passed[:oauth_signature_method]}"
    @query += "&oauth_timestamp=#{@passed[:oauth_timestamp]}"
    @query += "&oauth_token=#{@passed[:oauth_token]}" if @passed[:oauth_token]
    @query += "&oauth_verifier=#{@passed[:oauth_verifier]}" if @passed[:oauth_verifier]
    @query += "&oauth_version=#{@passed[:oauth_version]}"    
    @query += "&scope=#{@passed[:scope]}" if @passed[:scope]
        
    @signature_data = "GET&#{CGI::escape(options[:request_url])}&#{CGI::escape(@query)}"
    @secret = options[:oauth_secret] + "&"
    @secret += CGI::escape(options[:oauth_token_secret]) if options[:oauth_token_secret]

    
    @signature = CGI::escape(Base64.encode64(
                  OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),@secret,@signature_data)
                 ).chomp.gsub(/\n/, ""))
    @query += "&oauth_signature=#{@signature}"

    @post_array = [];
    @post_array.push("oauth_nonce=\"#{@passed[:oauth_nonce]}\"")
    @post_array.push("oauth_callback=\"#{@passed[:oauth_callback]}\"") if @passed[:oauth_callback]
    @post_array.push("oauth_signature_method=\"#{@passed[:oauth_signature_method]}\"")
    @post_array.push("oauth_timestamp=\"#{@passed[:oauth_timestamp]}\"")
    @post_array.push("oauth_token=\"#{@passed[:oauth_token]}\"") if @passed[:oauth_token]
    @post_array.push("oauth_verifier=\"#{@passed[:oauth_verifier]}\"") if @passed[:oauth_verifier]
    @post_array.push("oauth_consumer_key=\"#{@passed[:oauth_consumer_key]}\"")
    @post_array.push("oauth_signature=\"#{@signature}\"")
    @post_array.push("oauth_version=\"#{@passed[:oauth_version]}\"")
    @post_array.push("scope=\"#{@passed[:scope]}\"") if @passed[:scope]
    
    @post_string = @post_array.join(", ")
  
    res = `curl -g -m 3 -w '&status=%{http_code}' -H 'Authorization: OAuth #{@post_string}' -H 'Content-Type: application/atom+xml' -H 'GData-Version: 2.0' #{options[:request_url]}`
    return res.split('&').inject({}) do |hsh, i| kv = i.split('='); hsh[kv[0]] = kv[1]; hsh end
  end
  
  def facebook_find_or_create_account
    # get access token from facebook
    res = `curl "https://graph.facebook.com/oauth/access_token?client_id=#{Host.current.fb_app_id}&client_secret=#{Host.current.fb_app_secret}&code=#{params[:code]}&redirect_uri=#{oauth_response_url(:provider=>'facebook')}"`
    fb_user_json = `curl 'https://graph.facebook.com/me?#{res}'`
    fb_user = JSON.parse fb_user_json
    
    # make sure we got an authenticated response
    if !fb_user['id']
      flash[:error] = 'Unable to login via facebook'
      redirect_to login_path(:permalink => @calendar.permalink)
      return
    end
  
    # login and return if user already exists
    if @user = User.find_by_fb_id_and_site_id(fb_user['id'], Site.current.id)
      self.current_user = @user 
      cookies[:revent_auth] = '1';
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
      return
    end

    # login and return if email already in the system
    if @user = User.find_by_email_and_site_id(fb_user['email'], Site.current.id)
      @user.update_attribute 'fb_id', fb_user['id'] unless @user.fb_id
      self.current_user = @user 
      cookies[:revent_auth] = '1';
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
      return
    end
    
    # otherwise create new user
    @user = User.new :first_name => fb_user['first_name'],
                     :last_name => fb_user['last_name'],
                     :email => fb_user['email'],
                     :fb_id => fb_user['id']

    @user.set_site_id
    @user.assign_password
    @user.admin = false
    
    if @user.valid?
      @user.activate_new_user
      @user.save
      cookies[:revent_auth] = '1';
      self.current_user = @user
      
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
    else 
      flash[:error] = 'Unable to create account via facebook'
      render :action=>'signup'
    end
  end
    
  def google_find_or_create_account user_email
    # login and return if user already exists
    if @user = User.find_by_email_and_site_id(user_email, Site.current.id)
      self.current_user = @user 
      cookies[:revent_auth] = '1';
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
      return
    end

    # otherwise create new user
    @user = User.new :email => user_email

    @user.set_site_id
    @user.assign_password
    @user.admin = false
    
    if @user.valid?
      @user.activate_new_user
      @user.save
      cookies[:revent_auth] = '1';
      self.current_user = @user
      
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
    else 
      render :action=>'signup'
    end
  end
  
  def twitter_find_or_create_account twitter_id
  
    # login and return if user already exists
    if @user = User.find_by_twitter_id_and_site_id(twitter_id, Site.current.id)
      self.current_user = @user 
      cookies[:revent_auth] = '1';
      redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
      return
    end

    # otherwise create new user
    @user = User.new :twitter_id => twitter_id
    @user.set_site_id
    @user.assign_password
    @user.admin = false
    @user.activate_new_user
    # no email address yet, so don't validate
    @user.save_with_validation false
    cookies[:revent_auth] = '1';
    self.current_user = @user
    
    redirect_to session[:oauth_redirect_url] || manage_account_path(:permalink => @calendar.permalink)
  end
  
  def create 
    render :action=>'signup' and return if params[:user].nil?

    @user = User.new params[:user]
    @user.password = params[:user][:password] 
    @user.password_confirmation = params[:user][:password_confirmation] 
    @user.set_site_id
    @user.admin = false

    if @user.valid?
      @user.activate_new_user
      @user.save
      cookies[:revent_auth] = '1';
      self.current_user = @user
      
      if params[:redirect].nil? || params[:redirect].empty?
        redirect_to signup_path(:permalink => params[:permalink])
      else
        redirect_to params[:redirect]
      end
    else 
      render :action=>'signup'
    end
  end

  def new
    if params[:ajax]
      render :action => 'signup', :layout => false
    else
      render :action => 'signup'
    end
  end
=begin  Keeping this around just in case, delete if new methods don't cause problems with older sites 
  def signup
    @user = User.new(params[:user])
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'profile')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  #XXX: look at EventsController#create
  def new_signup
#    @user = User.new(params[:user])
    @supporter = DemocracyInActionSupporter.new(params[:democracy_in_action_supporter])
    @event = Event.new(params[:event])
    return unless request.post?
    @event.start = Time.local(params[:start][:year] || 2007, params[:start][:month] || 4, params[:start][:day] || 14, params[:time])
    raise @event.inspect
    #<input type="hidden" value="0,First_Name,Last_Name,Email,Phone," name="required" />
    #distributed_event_KEY = 239
    #email_trigger_KEYS=2590
    #Tracking_Code
    #Maximum_Attendees = 100
    #required = "Event_Name,Description,Start,End,Address,City,State,Directions,Zip,Maximum_Attendees"
    #updateRowValues=true
    #trigger="On New Distributed Event"
    #Status=Unconfirmed
    #add to group: 50838
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'profile')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
=end

  def logout
    self.current_user.forget_me if logged_in? && self.current_user.respond_to?(:forget_me)
    cookies.delete :auth_token
    cookies.delete :revent_auth
    reset_session
    response.etag = nil
    response.headers["Pragma"] = "no-cache"
    response.headers["Cache-Control"] = "no-cache"
    redirect_back_or_default(calendar_home_url(:permalink=>@calendar.permalink))
  end

  def forgot_password
    return unless request.post?
    if @user = User.find_by_site_id_and_email(Site.current, params[:email])
      @user.forgot_password
      @user.save
      flash[:notice] = "A password reset link has been sent to your email address" 
      redirect_to  :controller => 'account', :action => 'login', :permalink => @calendar.permalink 
    else
      flash[:notice] = "Could not find a user with that email address" 
    end
  end

  # this method is used both for initially setting a users password
  # and for resetting a users password if they have forgotten it.
  def reset_password
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    @password_reset_code_present = true if @user
    @user ||= current_user
    raise if @user.nil?
    return if @user unless params[:password]
    if (params[:password] == params[:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:password_confirmation]
      current_user.password = params[:password]
      current_user.activated_at ||= Time.now.utc
      @user.reset_password if @password_reset_code_present
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
    else
      flash[:notice] = "Password mismatch" 
    end  
    redirect_back_or_default(:controller => '/account', :action => 'index') 
  rescue
    logger.error "Invalid Reset Code entered" 
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?" 
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
end
