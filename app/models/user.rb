require 'digest/sha1'
require 'ostruct'
class User < ActiveRecord::Base
  attr_protected :password, :password_confirmation
  attr_accessor :sync_processed

  has_many :events, :foreign_key => 'host_id', :dependent => :destroy
  has_many :calendars
  has_many :reports, :dependent => :destroy
  has_many :rsvps
  has_many :attending, :through => :rsvps, :source => :event
  has_many :custom_attributes
  has_and_belongs_to_many :sponsors
  has_many :permissions, :class_name => 'UserPermission'

  belongs_to :profile_image, :class_name => 'Attachment', :foreign_key => 'profile_image_id'
  belongs_to :site
  before_create :set_site_id
  

  def as_json o={}
    super({
      :except => [
        :activation_code,
        :crypted_password,
        :salt,
        :remember_token,
        :remember_token_expires_at,
        :password_reset_code
      ],
      :include => {
        :events => {:only => [:id,:name,:start]},
        :attending => {:only => [:id,:name,:start]},
        :permissions => {:only => [:id, :name, :value]}
      }
    }.merge o)
  end
  
  def set_site_id
    self.site_id ||= Site.current.id if Site.current
  end
  
  def admin?
    admin || superuser?
  end

  def superuser?
    self.class.superuser_emails.include?(email)
  end

  def self.superuser_emails
    SUPERUSERS
  end

  def deferred?
    @deferred
  end
  attr_accessor :deferred

  def profile_complete?
    return false unless(
       first_name &&
       last_name &&
       email && 
       street && 
       city && 
       state && 
       postal_code
    )
    custom_attr_hash = {}
    self.custom_attributes.each {|a| custom_attr_hash[a.name] = a.value}
    self.site.config.required_custom_attributes.each do |name|
      return false if custom_attr_hash[name].blank?
    end
    return true
  end

  has_one :democracy_in_action_object, :as => :synced
  # (extract me) to the plugin!!!
  # acts_as_mirrored? acts_as_synced?
  attr_accessor :democracy_in_action
  
  after_save :purge_user_profile

  def sync_unless_deferred
    return if self.sync_processed
    self.sync_processed = true
    if Site.current.config.delay_dia_sync
      Rails.logger.info('***Delaying User Sync***') 
      self.enqueue_background_processes
    else
      Rails.logger.info('***Syncing User Inline***')
      background_processes
    end
  end

  def enqueue_background_processes
    @democracy_in_action = self[:democracy_in_action] || self.democracy_in_action || {}
    ShortLine.queue(  "revent_" + Host.current.hostname, 
                      "/workers/users", 
                      {:id => self.id, :dia => @democracy_in_action})
  end
  
  def background_processes
    self.sync_processed = true
    sync_to_democracy_in_action
    associate_partner_code
  end

  def associate_partner_code
    return unless self.partner_id
    sponsor = Sponsor.find_by_partner_code(self.partner_id)
    return unless sponsor
    sponsor.users << self unless sponsor.users.include? self
    sponsor.save
  end

  def associate_dia_host calendar
    self[:democracy_in_action] = {
      :supporter => {
        :link => {}
      }
    }
    if calendar.host_dia_group_key
      self[:democracy_in_action][:supporter][:link][:groups] = calendar.host_dia_group_key
    end
    if calendar.host_dia_trigger_key
      self[:democracy_in_action][:supporter][:email_trigger_KEYS] = calendar.host_dia_trigger_key
    end
  end

  def associate_dia_rsvp event, calendar
    self[:democracy_in_action] = {
      :supporter => {
        :link => {
          :event => event.democracy_in_action_key
        },
        :'_Status' => "Signed Up",
        :'_Type' => "Supporter"
      }
    }
    if calendar.rsvp_dia_group_key
      self[:democracy_in_action][:supporter][:link][:groups] = calendar.rsvp_dia_group_key
    end
    if calendar.rsvp_dia_trigger_key
      self[:democracy_in_action][:supporter][:email_trigger_KEYS] = calendar.rsvp_dia_trigger_key
    end
  end

  def associate_dia_report calendar
    self[:democracy_in_action] = {
      :supporter => {
        :link => {}
      }
    }
    if calendar.report_dia_group_key
      self[:democracy_in_action][:supporter][:link][:groups] = calendar.report_dia_group_key
    end
    if calendar.report_dia_trigger_key
      self[:democracy_in_action][:supporter][:email_trigger_KEYS] = calendar.report_dia_trigger_key
    end
  end

  def sync_to_democracy_in_action
    return true if Site.current.config.salsa_user.blank?

#   ted: now using :sync_unless_deferred
#    return true if deferred? #will be handled by background process

    Rails.logger.info('***Syncing User to DIA***') 
    @democracy_in_action = self[:democracy_in_action] || {}
#    $DEBUG = true
    @democracy_in_action_attrs = {} #attributes to be sent across the wire
    attributes.each do |k,v|
      @democracy_in_action_attrs[k.titleize.gsub(' ', '_')] = v
    end
    @democracy_in_action_attrs['Zip'] = self.postal_code
    @democracy_in_action_attrs['Tracking_Code'] = self.partner_id if self.partner_id

    # probably makes more sense to use an object wrapper so it can handle supporter_custom and whatnot
    # supporter = DemocracyInActionSupporter.new
    # supporter.custom << @democracy_in_action[:supporter_custom]
    # OR @democracyinaction.select {|k,v| k =~ /supporter_/}.each
    supporter = @democracy_in_action["supporter"] || @democracy_in_action[:supporter] || {}
    links = supporter.delete("link")

    require 'democracy_in_action'
    api = DemocracyInAction::API.new(Site.current.config.salsa_api_keys)
    api.authenticate
    supporter_key = api.save @democracy_in_action_attrs.merge(supporter).merge(:object => 'supporter')
    create_democracy_in_action_object :key => supporter_key, :table => 'supporter' unless self.democracy_in_action_object

    supporter_custom = @democracy_in_action["supporter_custom"] || @democracy_in_action[:supporter_custom] || {}
    supporter_custom_key = api.save( {:object=>'supporter_custom', 'supporter_KEY' => supporter_key}.merge(supporter_custom))

    links.each do |object, key|
      object_key = api.save( :object => "supporter_#{object}", 'supporter_KEY' => supporter_key, "#{object}_KEY" => key)
    end if links

    return true
  end

  def democracy_in_action_key
    democracy_in_action_object.key if democracy_in_action_object
  end

  def self.create_from_democracy_in_action_supporter(site, supporter)
    u = User.find_or_initialize_by_site_id_and_email(site.id, supporter.Email)
    u.first_name = supporter.First_Name
    u.last_name = supporter.Last_Name
    u.phone = supporter.Phone
    u.state = supporter.State
    u.postal_code = supporter.Zip
    unless u.democracy_in_action_key
      dia_obj = DemocracyInActionObject.new(:table => 'supporter', :key => supporter.key)
      dia_obj.save
    else
      dia_obj = u.democracy_in_action_object
    end
    unless u.save
      logger.warn("Validation error(s) occurred when trying to create user from DemocracyInActionSupporter: #{u.errors.inspect}")
      u.save_with_validation(false)
    end
    dia_obj.synced = u
    dia_obj.save
    u
  end
  
  def dia_group_key=(group_key)
    self.democracy_in_action ||= {}
    self.democracy_in_action['supporter'] ||= {}
    self.democracy_in_action['supporter']['link'] ||= {}
    self.democracy_in_action['supporter']['link']['groups'] = group_key
  end

  def dia_group_key
    democracy_in_action &&
    democracy_in_action['supporter'] && 
    democracy_in_action['supporter']['link'] && 
    democracy_in_action['supporter']['link']['groups']
  end

  def dia_trigger_key=(dia_trigger_key)
    self.democracy_in_action ||= {}
    self.democracy_in_action['supporter'] ||= {}
    self.democracy_in_action['supporter']['email_trigger_KEYS'] = dia_trigger_key
  end

  def dia_trigger_key
    democracy_in_action &&
    democracy_in_action['supporter'] && 
    democracy_in_action['supporter']['email_trigger_KEYS']
  end

  # end extract me

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :scope => :site_id, :case_sensitive => false
  before_save :encrypt_password, :sanitize_input
  before_create :make_activation_code
  after_save :deliver_email
  before_destroy :purge_user_profile

  def purge_user_profile
    return
    self.site.calendars.each do |c| 
      request = Typhoeus::Request.new("#{Site.current.config.varnish_server_url}/#{c.permalink}/user/#{self.id}", :method => 'PURGE')
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      logger.info "PURGED USER #{self.id}! STATUS: #{request.response.code}"
    end
  end

  def deliver_email
    UserMailer.forgot_password(self).deliver if self.recently_forgot_password?
    UserMailer.reset_password(self).deliver if self.recently_reset_password?
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    # check if this is a superuser account?
    if superuser_emails.include?(email)
      u = find_by_email(email)
    end

    # check if this user is legit for this site 
    u ||= find_by_site_id_and_email(Site.current.id, email, :conditions => 'activated_at IS NOT NULL')
    u && u.authenticated?(password) ? u : nil
  end

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Activates the user in the database.
  def activate_new_user
    @activated = true
    self.activated_at = Time.now.utc 
    self.activation_code = nil
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def self.find_or_build_related_user(user_params, cookies = {})
    user = self.find_or_initialize_by_site_id_and_email(Site.current.id, user_params[:email]) 
    user_params.reject! {|k,v| [:password, :password_confirmation].include?(k.to_sym)}
    user_params[:partner_id] ||= cookies[:partner_id] if cookies[:partner_id]

    user.attributes = user_params
    user
  end

  def full_name
    [first_name, last_name].compact.join(' ')
  end
  alias :name :full_name

  def address
    [street, street_2, city, state, postal_code].compact.join(', ')
  end
  
  def attending?(event)
    self.attending.any? {|e| e.id == event.id}
    self.events.any? {|e| e.id == event.id}
  end

  # most recently hosted or attended event
  def effective_event
    (self.events + self.attending).max{|a,b| a.end <=> b.end}
  end  

  # get calendar for most recently hosted or attended event
  def effective_calendar
    effective_event ? effective_event.calendar : (Site.current.calendars.detect {|c| c.current?} || Site.current.calendars.first)
  end
  
  def country
    CountryCodes.find_by_numeric(self.country_code)[:name]
  end

  def country=(name)
    self.country_code = CountryCodes.find_by_name(name)[:numeric]
  end

  def city_state
    [city, (state || country)].join(', ')
  end
    
  before_validation :assign_password
  def assign_password
    return true if self.password || crypted_password
    randomize_password
  end

  def randomize_password
    return true if crypted_password
    self.password = self.password_confirmation = User.random_password
  end

  def self.random_password
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def fill_in_blank_attributes params
    params.each do |key,value|
      self[key] = value if self[key].blank?
    end
  end

  def custom_attributes_data
    OpenStruct.new( Hash[ *custom_attributes.map { |attr| [ attr.name, attr.value ] }.flatten ] )
  end

  def custom_attributes_data=(values)
    values.each do | name, value |
      custom_attr = custom_attributes.find_by_name( name.to_s ) || custom_attributes.build( :name => name.to_s )
      custom_attr.value = value
      custom_attr.save
    end
  end

  def user_permissions_data
    return @user_permissions_data unless @user_permissions_data.nil?
    @user_permissions_data = {:sponsor_admin => [], :site_admin => false}
    permissions.each do |permission|
      case permission.name
      when "sponsor_admin"
        @user_permissions_data[:sponsor_admin].push(permission.value.to_i)
      when "site_admin"
        if permission.value == "true"
          @user_permissions_data[:site_admin] = true
        end
      end
    end
    @user_permissions_data 
  end

  # do not use
  def user_permissions_data=(values)
    values.each do | name, value |
      case name
      when :sponsor_admin
        user_permissions_data[:sponsor_admin].each do |sponsor_id|
          if !value.include? sponsor_id
            sponsor = permissions.find_by_name_and_value("sponsor_admin", sponsor_id)
            if !sponsor.nil?
              sponsor.destroy
            end
          end
        end
        value.each do |sponsor_id|
          if permissions.find_by_name_and_value("sponsor_admin", sponsor_id.to_s).nil?
            permissions.push(UserPermission.new(:name => "sponsor_admin", :value => sponsor_id.to_s))
          end
        end
      when :site_admin
        site_admin_permission = permissions.find_by_name_and_value("site_admin", "true")
        if value == true and site_admin_permission.nil?
          permissions.push(UserPermission.new(:name => "site_admin", :value => "true"))
        end
        if value == false and !site_admin_permission.nil?
          site_admin_permission.destroy
        end
      end
    end
    permissions.reload
    @user_permissions_data = nil unless @user_permissions_data.nil?
  end

  def site_admin?
    user_permissions_data[:site_admin]
  end

  def can_view_calendar
    site_admin?
  end

  def can_view_theme
    site_admin?
  end

  def to_admin_json
    to_json({
      :include => {
        :permissions => { 
          :only => [
            :id, :name, :value
          ]
        }
      }
    })
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def sanitize_input
      self.first_name = scrub(self.first_name) unless self.first_name.nil?
      self.last_name = scrub(self.last_name) unless self.last_name.nil?
      self.email = scrub(self.email) unless self.email.nil?
      self.postal_code = scrub(self.postal_code) unless self.postal_code.nil?
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
