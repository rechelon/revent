class Calendar < ActiveRecord::Base

  @@deleted_events = []
  @@all_events = []
  
  belongs_to :site
  belongs_to :parent, :class_name => 'Calendar', :foreign_key => 'parent_id'

  serialize :icon_upcoming
  serialize :icon_past
  serialize :icon_worksite

  has_one :democracy_in_action_object, :as => :synced
  has_one :hostform, :dependent => :destroy
  accepts_nested_attributes_for :hostform
  
  has_many :triggers, :dependent => :destroy
  has_many :categories, :dependent => :destroy do
    def construct_sql 
      result = super
      @counter_sql = @finder_sql = "categories.calendar_id IN (#{((proxy_owner.calendar_ids || []) << proxy_owner.id).join(',')})"
      result
    end
  end
  has_many :calendars, :class_name => 'Calendar', :foreign_key => 'parent_id'
  has_many :events, :dependent => :destroy do
    def construct_sql 
      result = super
      @counter_sql = @finder_sql = "events.calendar_id IN (#{((proxy_owner.calendar_ids || []) << proxy_owner.id).join(',')})"
      result
    end
    def unique_states
      states = proxy_target.collect {|e| e.state}.compact.uniq.select do |state|
        DaysOfAction::Geo::STATE_CENTERS.keys.reject {|c| :DC == c}.map{|c| c.to_s}.include?(state)
      end
      states.length
    end
    def find_updated_since( time )
      find :all, :include => [ :host, { :reports => :user }, :attendees ], :conditions => [ "events.updated_at > :time OR users.updated_at > :time OR reports.updated_at > :time", { :time => time } ]
    end

    def prioritize( sort )
      Event.prioritize(sort).by_query( :calendar_id => proxy_owner.id )
    end
  end
  has_many :reports do 
    def construct_sql 
      result = super
      @counter_sql = @finder_sql = "reports.calendar_id IN (#{((proxy_owner.calendar_ids || []) << proxy_owner.id).join(',')})"
      result
    end
  end
#  'reports.calendar_id IN #{(((calendar_ids || []) << id).join(","))}'


  scope :current, :conditions => {:current => true}
  
  validates_uniqueness_of :permalink, :scope => :site_id
  validates_presence_of :site_id, :permalink, :name
  #before_validation :escape_permalink
  before_create :attach_to_all_calendar
  
  def to_json o={}
    super({
      :except =>[:site_id],
      :include => [:hostform,:categories,:triggers]
    }.merge o)
  end

  def escape_permalink
    self.permalink = PermalinkFu.escape(self.permalink)
  end

  def self.any?
    self.count != 0
  end

  def past?
    self.event_end && (self.event_end + 1.day).at_beginning_of_day < Time.now
  end

  def theme
    @theme = Theme.find_by_id(self.theme_id) || Theme.new unless @theme
    @theme
  end

  def democracy_in_action_synced_table
    'distributed_event'
  end
  
  def democracy_in_action_key
    democracy_in_action_object.key if democracy_in_action_object
  end
  
  def democracy_in_action_key=(key)
    return if key.blank?
    obj = self.democracy_in_action_object || self.build_democracy_in_action_object(:table => 'distributed_event')
    obj.key = key 
    obj.save
  end
  
  def self.clear_deleted_events
    raise 'method deprecated, use DemocracyInAction::Util.clear_deleted_events'
  end

  def self.load_from_dia(id, *args)
    raise 'method deprecated, use DemocracyInAction::Util.load_from_dia'
  end

  def attach_to_all_calendar
    return if self.permalink == 'all'
    all_cal = site.calendars.find_by_permalink('all')
    return unless all_cal
    self.parent_id = all_cal.id
  end
  
  def get_supporter_group_keys
    return [] if supporter_dia_group_keys.nil?
    self.supporter_dia_group_keys.gsub(/\s/, '').split(',')
  end

  def past_event_cutoff
    return 5.years.ago unless self.days_before_event_expiration
    return self.days_before_event_expiration.days.ago
  end
end
