class Event < ActiveRecord::Base
  COUNTRY_CODE_USA = CountryCodes.find_by_name("United States of America")[:numeric] 
  COUNTRY_CODE_CANADA = CountryCodes.find_by_name("Canada")[:numeric] 
  MAP_JSON = {
    :except=>[
      :created_at,
      :updated_at,
      :campaign_key,
      :person_legislator_ids,
      :emailed_nearby_supporters,
      :max_attendees,
      :fallback_longitude,
      :fallback_latitude,
      :short_description,
      :letter_script,
      :call_script
    ],
    :methods=>[
      :past?,
      :custom_attributes_data
    ]
  }

  attr_accessor :suppress_email

  belongs_to :calendar
  belongs_to :host, :class_name => 'User', :foreign_key => 'host_id'
  belongs_to :category
  
  has_many :attachments, :dependent => :destroy
  has_many :documents, :class_name => 'Attachment', :conditions => Attachment.types_to_conditions([:document])
  has_many :images, :class_name => 'Attachment', :conditions => Attachment.types_to_conditions([:image])
  has_many :press_links, :through => :reports
  has_many :rsvps, :dependent => :destroy
  has_many :attendees, :through => :rsvps, :source => :user
  has_many :custom_attributes, :class_name => 'EventCustomAttribute', :dependent => :destroy
  has_many :blogs
  has_many :exportable_reports, :class_name=>'Report', :foreign_key => 'event_id', :include => :attachments, :order => 'reports.position', :dependent => :destroy  
  has_many :reports, :conditions => "reports.status = '#{Report::PUBLISHED}'", :include => :attachments, :order => 'reports.position', :dependent => :destroy do
    def attachments
      proxy_target.collect {|r| r.attachments}.flatten
    end
  end

  has_and_belongs_to_many :sponsors
  
  scope :searchable, :conditions => "(private = false OR private IS NULL) AND (worksite_event = false OR worksite_event is NULL )"
  scope :mappable, :conditions => ["(latitude <> 0 AND longitude <> 0) AND (state IS NOT NULL AND state <> '') AND country_code = ?", COUNTRY_CODE_USA]
  scope :worksite, :conditions => "worksite_event = 1"
  scope :private, :conditions => "private = 1"
  scope :not_private, :conditions => "(private = false OR private IS NULL)"
  scope :with_reports, :include => :reports, :conditions => ["reports.status = ?", Report::PUBLISHED]
  scope :sticky, :conditions => ["sticky = ?", true]
  scope :newer_than, lambda{|date| return {:conditions=>["end > ?", date]}}
  scope :older_than, lambda{|date| return {:conditions=>["start < ?", date]}}
  scope :all, lambda {{ }}
  scope :first, lambda {{ :limit => 1 }}
  scope :upcoming, lambda {{:conditions => ["end >= ?", Time.now], :order => 'start, state'}}
  scope :past, lambda {{:conditions => ["end <= ?", Time.now], :order => 'start DESC, state'}}
  scope :first_category, lambda { |category_id|
    { :order => "if( category_id = #{category_id.to_i}, 1, 0) DESC" }
  }
  scope :created_at, lambda { |order|
    { :order => "created_at #{order =~ /desc/i ? 'DESC' : 'ASC'}" }
  }
  
  geocoded_by :address_for_geocode
  before_validation :geocode
  before_save :set_calendar, :set_district, :clean_country_state, :clean_date_time, :set_host_name, :sanitize_input
  before_destroy :delete_from_democracy_in_action
  after_create :trigger_email
  
  validates_presence_of :name, :calendar_id

  def as_json o={}
    super({
      :except => [
        :short_description,
        :letter_script,
        :call_script
      ],
      :include => {
        :custom_attributes => {:only=>[:id,:name,:value]}
      },
      :methods => [:host_user_email]
    }.merge o)
  end

  def to_map_json o={}
    as_json(MAP_JSON.merge o)
  end

  def find_by_calendar_id( calendar_id )
  end

  def tags
    [] 
  end

  def set_start_from_date_and_time(date_string,time_string)
    time_string = "" if self.time_tbd?
    self.start = "#{time_string} #{date_string}".to_datetime
  end

  def set_end_from_date_and_time(date_string,time_string)
    time_string = "" if self.time_tbd?
    self.end = "#{time_string} #{date_string}".to_datetime  
  end

  def self.with_upcoming
    with_scope(:find => {:conditions => ["end >= ?", Time.now]}) do
      yield
    end
  end
  
  def self.with_past
    with_scope(:find => {:conditions => ["end <= ?", Time.now]}) do
      yield
    end
  end

  def privacy_level= privacy_level
    case privacy_level
    when 'worksite' 
      self.worksite_event = true
      self.private = false 
    when 'private' 
      self.private = true
      self.worksite_event = false 
    else
      self.private = false
      self.worksite_event = false 
    end
  end

  def privacy_level
    return 'worksite' if self.worksite_event
    return 'private' if self.private
    'public'
  end

  # finder-chainer!!!
  def self.prioritize(sort)
    return self.all if sort.nil?
    sort.inject(self.all) { |search, (finder, value) | sorted = search.send( finder.to_sym, value ) if scopes[ finder.to_sym ]; sorted || search }
  end

  scope :by_query, lambda {|query| 
    if query && !query.empty?
      Event.verify_calendar_id( query )
      {:conditions => query }
    else
      {}
    end
  }

  def self.verify_calendar_id(query)
    return query unless permalink = query.delete(:permalink) || calendar_id = query.delete(:calendar_id)
    if permalink 
      calendar_id ||= Site.current.calendars.inject(nil) { |memo, c| memo ||= ( c.permalink == permalink ? c.id : memo ) }
    end
    query[:calendar_id] = Calendar.find(calendar_id).calendar_ids + [ calendar_id ]
  end

  def state_is_canadian_province?
      usa_valid_states = DemocracyInAction::Helpers.state_options_for_select.map{|a| a[1]}
      all_valid_states = DemocracyInAction::Helpers.state_options_for_select(:include_provinces => true).map{|a| a[1]}
      valid_provinces = all_valid_states - usa_valid_states
      not state.blank? and valid_provinces.include?(state)
  end

  def clean_date_time
    if !self.start.blank?
      self.start = self.start.to_datetime
      self.end ||= self.start + 4.hours
      self.end = self.end.to_datetime
    end
  end
  
  def clean_country_state
    # usa is default country, if user sets state to 
    # canadian province, set country to canada
    if in_usa? and state_is_canadian_province? 
      country_code = COUNTRY_CODE_CANADA 
    end
    unless in_usa? or in_canada?
      state = nil 
    end
  end

  def validate
    validate_dates
    unless locationless?
      validate_city
      validate_country_code
      validate_postal_code
      validate_state
      validates_mappable
    end
  end
   
  def locationless?
    self.locationless
  end

  def show_map?
    return false if locationless?
    show_map
  end
  def validate_postal_code
    if in_usa?
      unless postal_code =~ /^\d{5}(-\d{4})?$/
        errors.add :postal_code, "is not a valid U.S. postal code"
      end
    elsif in_canada?
      unless postal_code =~ /^\D\d\D((-| )?\d\D\d)?$/
        errors.add :postal_code, "is not a valid Canadian postal code"
      end
    end      
  end

  def validate_city
    errors.add "City is blank" unless city
  end

  def validate_country_code
    errors.add "Country is blank" unless country_code 
  end

  def validate_state
    if in_usa?
      valid_us_states = DemocracyInAction::Helpers.state_options_for_select.map{|a| a[1]}
      if state.blank? or not valid_us_states.include?(state)
        errors.add :state, "is not a valid U.S. state"
      end      
    elsif in_canada?
      unless state_is_canadian_province?
        errors.add :state, "is not a valid Canadian province"
      end
    end
  end

  def validate_dates
    if (self.start && self.end) && (self.start > self.end)
      errors.add :start, "date must be before end date"
    end
    if (self.start && calendar.event_start) && (self.start < calendar.event_start.at_beginning_of_day)
      message = (calendar.event_end && (calendar.event_start.to_date == calendar.event_end.to_date)) ? "on" : "on or after"
      errors.add :start, "must be #{message} #{calendar.event_start.strftime('%B %e, %Y')}"
    end
    if (self.end && calendar.event_end) && (self.end > (calendar.event_end + 1.day).at_beginning_of_day)
      message = (calendar.event_start.to_date == calendar.event_end.to_date) ? "on" : "on or before"
      errors.add :end, "must be #{message} #{calendar.event_end.strftime('%B %e, %Y')}"
    end
  end
  
  def validates_mappable
    # only check that usa and canadian events are mappable
    if (in_usa? || in_canada?) && !(self.latitude && self.longitude)
      errors.add_to_base "Not enough information provided to place event on a map. Please give us at minimum a valid postal code."
    end
  end


  has_one :democracy_in_action_object, :as => :synced
  def democracy_in_action_synced_table
    'event'
  end

  attr_writer :democracy_in_action

  def sync_unless_deferred
    if Site.current.config.delay_dia_sync
      RAILS_DEFAULT_LOGGER.info('***Delaying Event Sync***') 
      ShortLine.queue("revent_" + Host.current.hostname, "/workers/events", {:id => self.id})
    else
      RAILS_DEFAULT_LOGGER.info('***Syncing Event Inline***')
      background_processes
    end
  end

  def background_processes
    sync_to_democracy_in_action
    associate_partner_code
  end

  def associate_partner_code
    return unless self.host.partner_id
    sponsor = Sponsor.find_by_partner_code(self.host.partner_id)
    return unless sponsor
    sponsor.events << self unless sponsor.events.include? self
    sponsor.save
  end

  def associate_dia_event hostform
    self[:democracy_in_action] = {
      :event => {
        :Maximum_Attendees => 10000,
        :Status => "Unconfirmed"
      }
    }
    if hostform and hostform.dia_event_tracking_code
      self[:democracy_in_action][:event][:Default_Tracking_Code] = hostform.dia_event_tracking_code
    end
  end

  def sync_to_democracy_in_action
    return true if Site.current.config.salsa_user.blank? 
    @democracy_in_action ||= {}
    extra = @democracy_in_action[:event] || {}
    event = self.to_democracy_in_action_event
    extra.each do |key, value|
      event.send "#{key}=", value
    end
    key = event.save
    self.create_democracy_in_action_object :key => key, :table => 'event' unless self.democracy_in_action_object
  end

  def suppress_email?
    return true if suppress_email
    false
  end

  def trigger_email
    return if suppress_email?
    calendar = self.calendar
    unless calendar.hostform and calendar.hostform.dia_trigger_key
      if calendar.triggers
        trigger = calendar.triggers.find_by_name("Host Thank You") 
      elsif Site.current.triggers
        trigger = Site.current.triggers.find_by_name("Host Thank You")
      end
      TriggerMailer.trigger(trigger, self.host, self).deliver if trigger
    end
  end
  
  def delete_from_democracy_in_action
    return unless Site.current.config.salsa_enabled?

    o = democracy_in_action_object
    return true unless o
    api = DemocracyInAction::API.new(Site.current.config.salsa_api_keys)
    api.authenticate
    api.delete :object => 'event', :key => self.democracy_in_action_key
    o.destroy
  end

  def to_democracy_in_action_event
    DemocracyInActionEvent.new do |e|
      e.Event_Name  = name
      e.Description = description
      e.Address     = location
      e.City        = city
      e.State       = state
      e.Zip         = postal_code
      e.Start       = "#{self.start.to_s(:db)}.0"
      e.End         = "#{self.end.to_s(:db)}.0"
      e.key         = democracy_in_action_key
      e.event_KEY   = democracy_in_action_key
      e.Latitude    = latitude
      e.Longitude   = longitude
      e.Directions  = directions
      e.supporter_KEY = (self.host ? self.host.democracy_in_action_key : '')
      e.distributed_event_KEY = self.calendar.democracy_in_action_key
    end
  end
  
  def democracy_in_action_key
    democracy_in_action_object.key if democracy_in_action_object
  end

  def address_for_geocode
    [location, city, state, postal_code].compact.join(', ').gsub /\n/, ' '
  end
  alias address address_for_geocode
  
  def start_date
    self.start.strftime("%B %d, %Y") unless self.start.blank?
  end
  
  def start_time
    self.start.strftime("%I:%M%p").downcase unless self.start.blank?
  end

  def form_start_date
    start ? start.strftime('%m/%d/%Y') : ''
  end
  
  def form_start_time
    start ? start.strftime('%I:%M %p') : ''
  end

  def form_end_date
    self.end ? self.end.strftime('%m/%d/%Y') : ''
  end
  
  def form_end_time
    self.end ? self.end.strftime('%I:%M %p') : ''
  end
 
  def segmented_date
    Hash[*([ :month, :day, :year, :month_name ].zip(self.start.strftime("%m %d %Y %B").split)).flatten]
  end
  
  def nearby_events
    self.calendar.events.searchable.near(self, 50).find(:all, :conditions => ["events.id <> ?", self.id])
  end

  def set_calendar
    if self.calendar and self.calendar.calendars.any?
      self.calendar = calendar.calendars.detect {|c| c.current? } || calendar.calendars.first
    end
  end

  def set_host_name
    return if host.nil?
    host_first_name = host.first_name
    host_last_name = host.last_name
  end

  def host_public_first_name
    host_alias ? host_first_name : host.first_name
  end

  def host_public_last_name
    host_alias ? host_last_name : host.last_name
  end

  def host_public_email
    host_alias ? host_email : host.email
  end

  def host_public_phone
    host_alias ? host_phone : host.phone
  end

  def host_public_full_name
    host_alias ? host_first_name+" "+host_last_name : host.full_name
  end

  def host_user_email
    return if self.host.nil?
    self.host.email
  end

  def host_user_email= email
    h = User.find_by_email email
    self.host = h unless h.nil?
  end

  def sanitize_input
    self.name = scrub(self.name) unless self.name.nil?
    self.description = scrub(self.description) unless self.description.nil?
    self.location = scrub(self.location) unless self.location.nil?
    self.city = scrub(self.city) unless self.city.nil?
    self.directions = scrub(self.directions) unless self.directions.nil?
  end
  
  # Move this to a library or DIA module or something
  require 'nokogiri'
  def self.postal_code_to_district(postal_code)
    Cache.get "district_for_postal_code_#{postal_code}" do
      begin
        # get congressional district based on postal code
        dia_warehouse = "http://warehouse.democracyinaction.org/dia/api/warehouse/append.jsp?id=radicaldesigns".freeze
        uri = dia_warehouse + "&postal_code=" + postal_code.to_s
        data = Nokogiri::XML(Kernel.open(uri))
        data = data.search('district')[0].children[0].content
      rescue
        data =''
      end
      data
    end
  end

  def set_district
    # don't lookup U.S. congressional district for non-us postal_codes
    return unless (self.country_code == COUNTRY_CODE_USA && 
                   self.postal_code =~ /^\d{5}(-\d{4})?$/)
    self.district = Event.postal_code_to_district(self.postal_code)
  end

  def national_map_coordinates
    @zip ||= ZipCode.find_by_zip(postal_code)
    if @zip
      [@zip.latitude, @zip.longitude]
    elsif latitude && longitude
      [latitude, longitude]
    else
      false
    end
  end

  def contact_phone
    if host? && host.phone?
      return host.phone
    else
      return ''
    end
  end

  def reports_disabled
    !reports_enabled?
  end
  alias :reports_disabled? :reports_disabled

  def reports_disabled=(value)
    inverted_value = value.respond_to?( :to_i ) ? value.to_i.zero? : !value
    self.reports_enabled = inverted_value
  end

  def reportable?
    reports_enabled? && !calendar.archived?
  end

  scope :reportable, :include => :calendar, :conditions => ["reports_enabled = ? AND calendars.archived = ?", true, false]

  def past?
    end_datetime = self.end || self.start
    end_datetime && (end_datetime < 11.hours.ago)
  end

  def in_usa?
    country_code == COUNTRY_CODE_USA
  end

  def in_canada?
    country_code == COUNTRY_CODE_CANADA
  end

  def country
    CountryCodes.find_by_numeric(self.country_code)[:name]
  end

  def city_state
    [city, (state.blank? ? country : state)].join(', ')
  end
  
  def country=(name)
    self.country_code = CountryCodes.find_by_name(name)[:numeric]
  end

  def attendees_high
    rprts = reports.reject{|r| not r.attendees or r.attendees <= 0}
    return nil if rprts.empty?
    rprts.map{|r| r.attendees}.max
  end
  
  def attendees_low
    rprts = reports.reject{|r| not r.attendees or r.attendees <= 0}
    return nil if rprts.empty?
    rprts.map{|r| r.attendees}.min
  end
  
  def attendees_average
    rprts = reports.reject{|r| not r.attendees or r.attendees <= 0}
    return nil if rprts.empty?
    rprts.map{|r| r.attendees}.sum / rprts.length
  end

  def duration_in_minutes
    ((self.end - self.start) / 60).to_i
  end
  
  # render letter/call scripts that can come from event model (scripts will 
  # have been created by host) or calendar (scripts will have been created 
  # by admin).  event (host) scripts over-ride calendar (admin) scripts
  def render_scripts
    city_state = [self.city, self.state].join(', ')
    self.letter_script ||= self.calendar.letter_script.gsub('CITY_STATE', city_state) if self.calendar.letter_script
    self.call_script ||= self.calendar.call_script.gsub('CITY_STATE', city_state) if self.calendar.call_script
  end
  #start time formatted the way facebook likes it
  def fb_start
    start.to_i
  end
  #json object to be used for facebook integration js
  def to_fb
    event_hash = attributes 
    event_hash[:fb_start] = fb_start
    event_hash.as_json
  end 

  def authorized_for_create?
    !emailed_nearby_supporters
  end
  
  def self.find_spotlight_events
    Event.find(:all, :spotlight => true)
  end

  def custom_attributes_data
    OpenStruct.new( Hash[ *custom_attributes.map { |attr| [ attr.name, attr.value ] }.flatten ] )
  end

  def custom_attributes_data=(values)
    values.each do | n, v|
      custom_attr = custom_attributes.find_by_name( n.to_s ) || custom_attributes.build( :name => n.to_s )
      custom_attr.value = v
      custom_attr.save
    end
  end


private
  def geocode
    # only geocode US or Canadian events
    return unless (country_code == COUNTRY_CODE_USA or country_code == COUNTRY_CODE_CANADA)
    if (geo = Geocoder.search(address_for_geocode)).count == 1
      self.latitude = geo[0].coordinates[0]
      self.longitude = geo[0].coordinates[1]
      self.precision = geo[0].precision
    elsif self.postal_code =~ /^\d{5}(-\d{4})?$/ and (zip = ZipCode.find_by_zip(self.postal_code))
      self.latitude, self.longitude = zip.latitude, zip.longitude if zip
      self.precision = 'zip'
    elsif self.postal_code   # handle US postal codes not in ZipCode table and Canadian postal
      if (geo = Geocoder.search(self.postal_code)).count == 1
        self.latitude = geo[0].coordinates[0]
        self.longitude = geo[0].coordinates[1]
        self.precision = geo[0].precision
      end
    end
  end

end
