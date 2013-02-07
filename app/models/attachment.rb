class Attachment < ActiveRecord::Base

  before_save :sanitize_input
  after_validation :set_event_id, :on => :create

  mount_uploader :filename, AttachmentUploader

  belongs_to :user
  belongs_to :report
  belongs_to :event

  @@audio_content_types = ['application/ogg'].freeze
  @@document_content_types = ['application/pdf', 'application/msword', 'text/plain']

  @@audio_condition = ['content_type LIKE ? OR content_type IN (?)', 'audio%', @@audio_content_types].freeze
  @@image_condition = ['content_type LIKE ?', 'image%'].freeze
  @@document_condition = ['content_type IN (?)', @@document_content_types].freeze
  cattr_reader *%w(audio image document).collect! { |t| "#{t}_condition".to_sym }
  def self.blah
    sanitize_sql(['content_type LIKE ?', 'image%'])
  end

  class << self
    def audio?(content_type)
      content_type.to_s =~ /^audio/ || @@audio_content_types.include?(content_type)
    end

    def image?(content_type)
      content_type.to_s =~ /^image/
    end

    def document?(content_type)
      @@document_content_types.include?(content_type)
    end

    def other?(content_type)
      ![:image, :audio].any? { |a| send("#{a}?", content_type) }
    end

    def find_all_by_content_types(types, *args)
      with_content_types(types) { find *args }
    end

    def with_content_types(types, &block)
      scope(:find => { :conditions => types_to_conditions(types) }, &block)
    end

    def types_to_conditions(types)
      type_conditions = types.collect! { |t| send("#{t}_condition") }
      exp, args = [], []
      type_conditions.each do |t|
        exp << "("+t.first+")"
        args += t.slice(1, t.count)
      end
      [exp.join(" OR "), *args]
    end
  end

  [:audio, :image].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", content_type) }
  end

  def set_event_id
    self.event_id ||= report.event_id if report
  end

  def primary!
    event = self.event || self.report.event
    event.reports.collect {|r| r.attachments}.flatten.each do |attachment|
      next if attachment == self
      attachment.update_attribute(:primary, false) if attachment.primary?
    end
    self.update_attribute(:primary, true)
  end

  def sanitize_input
    self.caption = scrub(self.caption) unless self.caption.nil?
  end

end
