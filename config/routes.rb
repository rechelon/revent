Revent::Application.routes do
  match "/", :to => "calendars#show", :as => "home", :format => "html"
  match "logged_exceptions/:action(.:format)(/:id)", :controller => "logged_exceptions"
  match "crossdomain.xml", :controller => "cross_domain", :format => "xml"
  match "events/upcoming/rss", :to => "events#upcoming_rss", :format => "xml"
  match "events/past/rss", :to => "events#past_rss", :format => "xml"
  match "events/rss", :format => "xml"
  match ":permalink/events/upcoming/rss", :to => "events#upcoming_rss", :format => "xml"
  match ":permalink/events/past/rss", :to => "events#past_rss", :format => "xml"
  match ":permalink/events/rss", :to => "events#rss", :format => "xml"
  match ":permalink/map.:format", :to => "maps#index"

  namespace :admin do
    match 'events/alert_nearby_supporters'
    match 'events/export'
    match 'users/export'
    match 'users/reset_password/:id', :to => 'users#reset_password'
    match 'reports/export'
    match 'calendars/set_default/:id', :to => 'calendars#set_default'
    match 'themes/clone/:id', :to => 'themes#clone'
    resources :events, :users, :calendars, :reports, :triggers, :categories, :sponsors, :permissions, :themes, :theme_elements

    match 'users/:action/:id(.:format)', :controller => 'users'
    match 'users/:action(.:format)', :controller => 'users'
  
    match 'events.:format', :to => 'events#index'
    match 'events/:action/:id(.:format)', :controller => 'events'
    match 'events/:action.:format', :controller => 'events'
  
    match ':permalink/reports/:action/:id(.:format)', :controller => 'reports'
    match ':permalink/reports/:action.:format', :controller => 'reports'
  
    match 'calendars/:action/:id(.:format)', :controller => 'calendars'
    match 'calendars/:action.:format', :controller => 'calendars'

    match 'triggers/:action/:id(.:format)', :controller => 'triggers'
    match 'triggers/:action.:format', :controller => 'triggers'

    match 'categories/:action/:id(.:format)', :controller => 'categories'
    match 'categories/:action.:format', :controller => 'categories'

    match 'hostforms/:action/:id(.:format)', :controller => 'hostforms'
    match 'hostforms/:action.:format', :controller => 'hostforms'

    match 'categories/:action/:id(.:format)', :controller => 'categories'
    match 'categories/:action.:format', :controller => 'categories'

    match 'reports/:action/:id(.:format)', :controller => 'reports'
    match 'reports/:action.:format', :controller => 'reports'

    delete 'cache', :controller => 'caches#destroy'
  end

  namespace :purge do
    match 'events/:action/:id', :controller => 'events'
    match 'reports/:action/:id', :controller => 'reports'
  end

  # routes for workers (shortline)
  namespace :workers do
    match 'events/:action', :controller => 'events'
    match 'reports/:action', :controller => 'reports'
    match 'users/:action', :controller => 'users'
  end

  match 'partners/:id', :controller => 'partners'
  match ':permalink/partners/:id', :controller => 'partners'

  match ':permalink/events/fb_rsvp/:id', :to => 'events#fb_rsvp'

  match ':permalink/events/copy/:id', :to => 'events#copy', :as => "copy_event"
  match ':permalink/events/email_host/:id', :to => 'events#email_host', :as => "email_host"
 
  controller :events do
    scope :action => :new do
      match ':permalink/signup/:partner_id', :as => 'signup'
      match 'calendars/:calendar_id/signup/:partner_id'
      match 'signup/(:partner_id)'
    end 
  end

  match 'attachments/:id1/:id2/*file', :to => 'attachments#show', :constraints => { :id1 => /\d+/, :id2 => /\d+/ }
  match 'attachments/:id/*file', :to => 'attachments#show', :constraints => { :id => /\d+/ }

  match 'profile/events/save_fb_connect_id', :to => 'account/events#save_fb_connect_id', :as => 'fb_event_save'
  match ':permalink/profile/events/save_fb_connect_id', :to => 'account/eventsi#save_fb_connect_id', :as => 'fb_event_save'
  match 'profile/events', :to => 'account/events#index', :as => 'manage_account'
  match ':permalink/profile/events', :to => 'account/events#index', :as => 'manage_account'

  controller :'account/events' do
    scope :constraints => {:id => /\d+/} do
      scope :action => :show do
        match 'profile/events/:id'
        match ':permalink/profile/events/:id'
      end
      match 'profile/events/:action/:id'
      match ':permalink/profile/events/:action/:id'
    end
  end

  match 'admin/login'

  controller :account do
    match ':permalink/create_account', :action => 'create', :as => 'create_user'
    match 'create_account', :action => 'create', :as => 'create_user'
    match ':permalink/login', :action => 'login', :as => 'login'
    match 'login', :action => 'login', :as => 'login'
    match ':permalink/logout', :action => 'logout', :as => 'logout'
    match 'logout', :action => 'logout', :as => 'logout'
    match 'profile', :action => 'profile', :as => 'profile'
    match ':permalink/profile', :action => 'profile', :as => 'profile'
    match ':permalink/rsvped/:event_id', :action => 'rsvped', :format => 'json', :as => 'rsvped'
    match ':permalink/new_account/(:partner_id)', :action => 'new', :as => 'new_user'
    match 'new_account/(:partner_id)', :action => 'new', :as => 'new_user'
    match 'calendars/:calendar_id/new_account/(:partner_id)', :action=>'new'
    match 'login_popup/(:partner_id)', :action => 'login_popup', :as => 'login_popup'
    match ':permalink/login_popup/(:partner_id)', :action => 'login_popup', :as => 'login_popup'
    match 'oauth/request/:provider', :action => 'oauth_request', :as => 'oauth_request'
    match 'oauth/response/:provider', :action => 'oauth_response', :as => 'oauth_request'
  end

  match 'cache/clear_calendars', :as => 'clear_calendars'

  controller :'account/blogs' do
    match 'profile/blogs/:action/:id'
    match ':permalink/profile/blogs/:action/:id'
  end

  match 'ally/:referrer', :to => 'events#ally', :as => 'ally'

  controller :reports do
    match ':permalink/reports/new/', :action => 'new', :as => 'new_report'
    match ':permalink/reports/', :action => 'index', :as => 'reports'

    match ':permalink/reports/search/state/:state', :action => 'search', :constraints => /\w{2}/, :as => 'report_state_search'
    match ':permalink/reports/search/zip/:zip', :action => 'search', :constraints => /\d{5}/, :as => 'report_zip_search'
    match 'reports/search/state/:state', :action => 'search', :constraints => /\w{2}/
    match 'reports/search/zip/:zip', :action => 'search', :constraints => /\d{5}/

    match ':permalink/reports/photos/tagged/:tag', :action => 'photos'
    match ':permalink/reports/video/tagged/:tag', :action => 'video'

    match ':permalink/reports/:event_id', :action => 'show', :constraints => {:event_id => /\d+/}, :as => 'report'
    match 'reports/:event_id', :action => 'redirect_to_show_with_permalink', :constraints => {:event_id => /\d+/}, :as => 'legacy_report'
  end

  match ':permalink/:controller/page/:page', :action => 'list'
  match ':controller/page/:page', :action => 'list'
  match ':controller/search/zip/:zip/:page', :action => 'search'

  match ':permalink/events/show/:id', :to => 'events#show', :format => 'html'

  match 'events/international/page/:page', :to => 'events#international'
  match ':permalink/events/international/page/:page', :to => 'events#international'

  # Install the default route as the lowest priority.
  match ':controller/:action/:id(.:format)'
  match ':controller/:action.:format'

  match ':permalink', :to => 'calendars#show', :as => 'calendar_home'
  match ':permalink/embed', :to => 'calendars#embed'

  match ':permalink/:controller/:action/:id(.:format)'
  match ':permalink/:controller/:action.:format'
end
