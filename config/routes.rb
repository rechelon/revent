ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  
  Jammit::Routes.draw(map)
  
  map.home '', :controller => 'calendars', :action => 'show', :format => 'html'
  map.connect "logged_exceptions/:action/:id", :controller => "logged_exceptions"
  map.connect "logged_exceptions/:action.:format", :controller => "logged_exceptions"
  map.connect 'crossdomain.xml', :controller => 'cross_domain', :format => 'xml'
  map.connect 'events/upcoming/rss', :controller => 'events', :action => 'upcoming_rss', :format => 'xml'
  map.connect 'events/past/rss', :controller => 'events', :action => 'past_rss', :format => 'xml'
  map.connect 'events/rss', :controller => 'events', :action => 'rss', :format => 'xml'
  map.connect ':permalink/events/upcoming/rss', :controller => 'events', :action => 'upcoming_rss', :format => 'xml'
  map.connect ':permalink/events/past/rss', :controller => 'events', :action => 'past_rss', :format => 'xml'
  map.connect ':permalink/events/rss', :controller => 'events', :action => 'rss', :format => 'xml'
  map.connect ':permalink/map.:format', :controller => 'maps', :action => 'index'

  map.namespace(:admin) do |admin|
    admin.connect 'events/alert_nearby_supporters', :controller => 'events', :action =>'alert_nearby_supporters'
    admin.connect 'events/export', :controller => 'events', :action =>'export'
    admin.connect 'users/export', :controller => 'users', :action =>'export'
    admin.connect 'users/reset_password/:id', :controller => 'users', :action =>'reset_password'
    admin.connect 'reports/export', :controller => 'reports', :action =>'export'
    admin.connect 'calendars/set_default/:id', :controller => 'calendars', :action =>'set_default'
    admin.connect 'themes/clone/:id', :controller => 'themes', :action =>'clone'
    admin.resources :events, :users, :calendars, :reports, :triggers, :categories, :sponsors, :permissions, :themes, :theme_elements
  end

  map.namespace(:purge) do |purge|
    purge.connect 'events/:action/:id', :controller => 'events'
    purge.connect 'reports/:action/:id', :controller => 'reports'
  end
  
  map.connect 'admin/users/:action/:id.:format', :controller => 'admin/users'
  map.connect 'admin/users/:action.:format', :controller => 'admin/users'
  map.connect 'admin/users/:action/:id', :controller => 'admin/users'
  
  map.connect 'admin/events.:format', :controller => 'admin/events', :action => 'index'
  map.connect 'admin/events/:action/:id.:format', :controller => 'admin/events'
  map.connect 'admin/events/:action.:format', :controller => 'admin/events'
  map.connect 'admin/events/:action/:id', :controller => 'admin/events'
 
  map.connect 'admin/:permalink/reports/:action/:id.:format', :controller => 'admin/reports'
  map.connect 'admin/:permalink/reports/:action.:format', :controller => 'admin/reports'
  map.connect 'admin/:permalink/reports/:action/:id', :controller => 'admin/reports'
 
  map.connect 'admin/calendars/:action/:id.:format', :controller => 'admin/calendars'
  map.connect 'admin/calendars/:action.:format', :controller => 'admin/calendars'
  map.connect 'admin/calendars/:action/:id', :controller => 'admin/calendars'

  map.connect 'admin/triggers/:action/:id.:format', :controller => 'admin/triggers'
  map.connect 'admin/triggers/:action.:format', :controller => 'admin/triggers'
  map.connect 'admin/triggers/:action/:id', :controller => 'admin/triggers'

  map.connect 'admin/categories/:action/:id.:format', :controller => 'admin/categories'
  map.connect 'admin/categories/:action.:format', :controller => 'admin/categories'
  map.connect 'admin/categories/:action/:id', :controller => 'admin/categories'

  map.connect 'admin/hostforms/:action/:id.:format', :controller => 'admin/hostforms'
  map.connect 'admin/hostforms/:action.:format', :controller => 'admin/hostforms'
  map.connect 'admin/hostforms/:action/:id', :controller => 'admin/hostforms'

  map.connect 'admin/categories/:action/:id.:format', :controller => 'admin/categories'
  map.connect 'admin/categories/:action.:format', :controller => 'admin/categories'
  map.connect 'admin/categories/:action/:id', :controller => 'admin/categories'

  map.connect 'admin/reports/:action/:id.:format', :controller => 'admin/reports'
  map.connect 'admin/reports/:action.:format', :controller => 'admin/reports'
  map.connect 'admin/reports/:action/:id', :controller => 'admin/reports'

  map.connect 'admin/cache', :controller => 'admin/caches', :only => :delete, :action => 'destroy'
# end of work-around

  # routes for workers (job board)
  map.connect 'workers/events/:action', :controller => 'workers/events'
  map.connect 'workers/reports/:action', :controller => 'workers/reports'
  map.connect 'workers/users/:action', :controller => 'workers/users'

  map.connect 'partners/:id', :controller => 'partners'
  map.connect ':permalink/partners/:id', :controller => 'partners'

  map.connect ':permalink/events/fb_rsvp/:id', :controller => 'events', :action => 'fb_rsvp'

  map.copy_event ':permalink/events/copy/:id', :controller => 'events', :action => 'copy'
  map.email_host ':permalink/events/email_host/:id', :controller => 'events', :action => 'email_host'
  
  map.with_options :controller => 'events', :action => 'new' do |m|
    m.signup ':permalink/signup/:partner_id', :defaults => {:partner_id => nil}
    m.connect 'calendars/:calendar_id/signup/:partner_id', :defaults => {:partner_id => nil}
    m.connect 'signup/:partner_id', :defaults => {:partner_id => nil}
  end

  map.connect '/attachments/:id1/:id2/*file', :controller => 'attachments', :action => 'show', :requirements => { :id1 => /\d+/, :id2 => /\d+/ }
  map.connect '/attachments/:id/*file', :controller => 'attachments', :action => 'show', :requirements => { :id => /\d+/ }
  map.fb_event_save '/profile/events/save_fb_connect_id', :controller=> 'account/events', :action => 'save_fb_connect_id'
  map.fb_event_save '/:permalink/profile/events/save_fb_connect_id', :controller=> 'account/events', :action => 'save_fb_connect_id'
  map.manage_account '/profile/events', :controller=>'account/events', :action => 'index'
  map.manage_account '/:permalink/profile/events', :controller=>'account/events', :action => 'index'
  map.with_options :controller => 'account/events' do |m|
    m.connect '/profile/events/:id', :action => 'show', :requirements => {:id => /\d+/}
    m.connect '/:permalink/profile/events/:id', :action => 'show', :requirements => {:id => /\d+/}
    m.connect '/profile/events/:action/:id'
    m.connect '/:permalink/profile/events/:action/:id'
  end

  map.connect '/admin/login', :controller => 'admin', :action => 'login'
  map.with_options :controller => 'account' do |m|
    m.create_user ':permalink/create_account', :action => 'create'
    m.create_user '/create_account', :action => 'create'
    m.login   ':permalink/login',   :action => 'login'
    m.login   '/login',   :action => 'login'
    m.logout  ':permalink/logout',  :action => 'logout'
    m.logout  '/logout',  :action => 'logout'
    m.profile '/profile', :action => 'profile'
    m.profile ':permalink/profile', :action => 'profile'
    m.rsvped ':permalink/rsvped/:event_id', :action => 'rsvped', :format => 'json'
    m.new_user ':permalink/new_account/:partner_id',  :action => 'new', :defaults=>{:partner_id=>nil}
    m.new_user '/new_account/:partner_id',   :action => 'new', :defaults=>{:partner_id=>nil}
    m.connect 'calendars/:calendar_id/new_account/:partner_id', :action=>'new',:defaults => {:partner_id => nil}
    m.login_popup '/login_popup/:partner_id', :action => 'login_popup', :defaults=>{:partner_id=>nil} 
    m.login_popup '/:permalink/login_popup/:partner_id', :action => 'login_popup', :defaults=>{:partner_id=>nil}
    m.oauth_request '/oauth/request/:provider', :action => 'oauth_request'
    m.oauth_response '/oauth/response/:provider', :action => 'oauth_response'
  end  

  map.with_options :controller => 'cache' do |m|
    m.clear_calendar_cache '/cache/clear_calendars', :action => 'clear_calendars'
  end
  
  map.with_options :controller => 'account/blogs' do |m|
    m.connect '/profile/blogs/:action/:id'
    m.connect ':permalink/profile/blogs/:action/:id'
  end

  map.ally '/ally/:referrer', :controller => 'events', :action => 'ally', :defaults => {:referrer => ''}

  map.new_report ":permalink/reports/new/", :controller => "reports", :action => "new"
  map.reports ":permalink/reports/", :controller => "reports", :action => "index"
                                           
  map.report_state_search ":permalink/reports/search/state/:state", :controller => "reports",
                                           :action => "search",
                                           :requirements => { :state => /\w{2}/ }
  map.report_zip_search ":permalink/reports/search/zip/:zip",  :controller => "reports",
                                        :action => "search",
                                        :requirements => { :zip => /\d{5}/ }
  map.connect "reports/search/state/:state", :controller => "reports",
                                           :action => "search",
                                           :requirements => { :state => /\w{2}/ }
  map.connect "reports/search/zip/:zip",  :controller => "reports",
                                        :action => "search",
                                        :requirements => { :zip => /\d{5}/ }

  map.connect ':permalink/reports/photos/tagged/:tag', :controller => 'reports', :action => 'photos'
  map.connect ':permalink/reports/video/tagged/:tag', :controller => 'reports', :action => 'video'
  map.report ':permalink/reports/:event_id', :controller => 'reports', :action => 'show', :requirements => {:event_id => /\d+/}
  map.legacy_report 'reports/:event_id', :controller => 'reports', :action => 'redirect_to_show_with_permalink', :requirements => {:event_id => /\d+.*/}

  map.connect ':permalink/:controller/page/:page', :action => 'list'
  map.connect ':controller/page/:page', :action => 'list'
  map.connect ':controller/search/zip/:zip/:page', :action => 'search'

  map.connect ':permalink/events/show/:id', :controller => 'events', :action => 'show', :format => 'html'

  map.connect 'events/international/page/:page', :controller => 'events', :action => 'international'
  map.connect ':permalink/events/international/page/:page', :controller => 'events', :action => 'international'


  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'

  map.calendar_home ':permalink', :controller => 'calendars', :action => 'show' 
  map.connect ':permalink/embed', :controller =>'calendars', :action =>'embed'
  map.connect ':permalink/:controller/:action/:id.:format'
  map.connect ':permalink/:controller/:action.:format'
  map.connect ':permalink/:controller/:action/:id'
end
