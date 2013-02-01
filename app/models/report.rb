class Report < ActiveRecord::Base
  PUBLISHED = 'published'
  UNPUBLISHED = 'unpublished'

  attr_accessor :sync_processed
  attr_accessor :press_link_data
  attr_accessor :embed_data
  attr_accessor :akismet_params

  belongs_to :event
  belongs_to :user
  belongs_to :calendar

  acts_as_list :scope => :event_id

  has_many :attachments, :dependent => :destroy
  has_many :embeds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :press_links, :dependent => :destroy
  has_and_belongs_to_many :sponsors
  validates_associated :attachments, :press_links, :embeds, :user
  validate :event_allows_reporting
  def event_allows_reporting
    errors.add_to_base "this event does not allow reports" unless event.reports_enabled?
  end

  scope :published, :conditions => ["status = ?", PUBLISHED]
  scope :featured, :conditions => ["featured = ?", true]

  before_save :update_calendar, :sanitize_input
  after_save :save_user_if_dirty

  def to_json o={}
    super({
      :include => {
        :event => {:only => [:id,:name,:start,:state,:postal_code,:city]},
        :user => {:only => [:id,:first_name,:last_name,:email]}
      },
      :methods => :primary_image
    }.merge o)
  end
  
  def update_calendar
    self.calendar_id = self.event.calendar_id
  end

  def sanitize_input
    self.text = scrub(self.text) unless self.text.nil?
    self.text2 = scrub(self.text2) unless self.text2.nil?
  end

  def primary_image
    image = self.attachments.detect{|a| a.image? }
    image ? image.public_filename(:list) : nil 
  end 

  def save_user_if_dirty
    #self.user.save if self.user.changed?
    #we don't have the chaned method until rails 2.1.0
    #TODO upgrade to rails 2.1.0

    self.user.save unless self.user.nil?
  end

  def sync_unless_deferred
    return if self.sync_processed
    self.sync_processed = true
    if Site.current.config.delay_dia_sync
      RAILS_DEFAULT_LOGGER.info('***Delaying Report Sync***') 
      self.enqueue_background_processes
    else
      RAILS_DEFAULT_LOGGER.info('***Syncing Report Inline***')
      self.background_processes
    end
  end

  def enqueue_background_processes
    ShortLine.queue("revent_" + Host.current.hostname, "/workers/reports", {:id => self.id, :embed_data => self.embed_data, :press_link_data => self.press_link_data})
  end

  def background_processes
    self.sync_processed = true
    self.associate_partner_code
    self.make_local_copies!
    self.build_press_links
    self.build_embeds
    #self.build_videos
    self.move_to_temp_files! # this needs to be re-implemented
    self.save!
  end

  def associate_partner_code
    return unless self.user.partner_id
    sponsor = Sponsor.find_by_partner_code(self.user.partner_id)
    return unless sponsor
    sponsor.reports << self unless sponsor.reports.include? self
  end

    
  def process!
    background_processes
  end

  def trigger_email
    calendar = self.event.calendar
    if calendar.report_dia_trigger_key.blank?
      if calendar.triggers.any? || Site.current.triggers.any?
        trigger = calendar.triggers.find_by_name("Report Thank You") || Site.current.triggers.find_by_name("Report Thank You")
        require 'ostruct'
        reporter = OpenStruct.new(:name => self.reporter_name, :email => self.reporter_email)
        TriggerMailer.trigger(trigger, reporter, self.event).deliver if trigger
      end
    end
  end
    
  def primary!
    self.move_to_top
  end

  def primary?
    self.first?
  end

  validates_presence_of :event_id, :text

  def published?
    PUBLISHED == status
  end

  def self.publish(id)
    update(id, :status => PUBLISHED)
  end

  def self.unpublish(id)
    update(id, :status => UNPUBLISHED)
  end

  def publish
    update_attribute(:status, PUBLISHED)
  end

  def unpublish
    update_attribute(:status, UNPUBLISHED)
  end

  def reporter_name
    user ? user.full_name : read_attribute('reporter_name')
  end

  def reporter_first_name
    user ? user.first_name : read_attribute('reporter_name').split(' ')[0]
  end

  def reporter_email
    user ? user.email : read_attribute('email')
  end

  def build_press_links
    return true unless press_link_data
    links = []
    (1..press_link_data.count).each do |i|
      links << press_link_data[i.to_s] unless press_link_data[i.to_s][:url].blank?
    end
    self.press_links.build(links) if links.any?
    true
  end

  def attachment_data=(data)
    attaches = []
    (1..data.count).each do |i|
      attaches << data[i.to_s] unless data[i.to_s][:uploaded_data].blank?
    end
    self.attachments.build(attaches) if attaches.any?
  end

  # copy tempfiles to presistent files because attachments stored as 
  # tempfiles are not guaranteed to persist if app server dies
  def make_local_copies!
    self.attachments.each {|a| a.make_local_copy}
  end

  # undo make_local_copies so that local attachment files
  # get deleted (at some point)
  def move_to_temp_files!
    self.attachments.each {|a| a.move_to_temp_files}
  end

  def build_embeds
    return true unless embed_data
    embeddables = []
    (1..embed_data.count).each do |i|
      embeddables << embed_data[i.to_s] unless embed_data[i.to_s][:html].blank?
    end
    self.embeds.build(embeddables) if embeddables.any?
    true
  end

  def self.akismet_params( request )
    { 
      :user_ip => request.remote_ip,
      :user_agent => request.user_agent,
      :referrer => request.referer 
    }
  end
  
  def akismet_params
    @akismet_params ||= {} 
  end

  def spammy?
    return false unless Site.current.config.is_akismet_enabled

    akismet = Akismet.new Site.current.config.akismet_api_key, Site.current.config.akismet_domain_name

    akismet.comment_check( 
        akismet_params.merge({ 
# test akismet: author 'viagra-test-123' will always return true 
#          :comment_author => 'viagra-test-123',   
          :comment_author => reporter_name,
          :comment_author_email => reporter_email, 
          :comment_content => text })
     )
  end

  def attachments_count
    attachments.count
  end

  def embeds_count
    embeds.count
  end

  def reporter_data=(reporter_attributes)
    self.user = User.find_or_initialize_by_site_id_and_email( Site.current.id, reporter_attributes[:email] )
    self.user.attributes = reporter_attributes
  end
end
