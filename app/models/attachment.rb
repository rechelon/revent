class Attachment < ActiveRecord::Base

  # ted: temp_data needed to be added when we upgraded to rails 2.3, previously attachment_foo did this
  # ( aka maybe something is broken with atachment_fu )
  attr_writer :temp_data

  before_save :sanitize_input

  # NOTE: lifted wholesale from Mephisto
  # used for extra mime types that dont follow the convention
  @@extra_content_types = { :audio => ['application/ogg'], :video => ['application/x-shockwave-flash'], :pdf => ['application/pdf'] }.freeze
  cattr_reader :extra_content_types

  # use #send due to a ruby 1.8.2 issue
  @@video_condition = send(:sanitize_sql, ['content_type LIKE ? OR content_type IN (?)', 'video%', extra_content_types[:video]]).freeze
  @@audio_condition = send(:sanitize_sql, ['content_type LIKE ? OR content_type IN (?)', 'audio%', extra_content_types[:audio]]).freeze
  @@image_condition = send(:sanitize_sql, ['content_type IN (?)', Technoweenie::AttachmentFu.content_types]).freeze
  @@other_condition = send(:sanitize_sql, [
    'content_type NOT LIKE ? AND content_type NOT LIKE ? AND content_type NOT IN (?)',
    'audio%', 'video%', (extra_content_types[:video] + extra_content_types[:audio] + Technoweenie::AttachmentFu.content_types)]).freeze
  cattr_reader *%w(video audio image other).collect! { |t| "#{t}_condition".to_sym }

  class << self
    def video?(content_type)
      content_type.to_s =~ /^video/ || extra_content_types[:video].include?(content_type)
    end

    def audio?(content_type)
      content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(content_type)
    end

    def other?(content_type)
      ![:image, :video, :audio].any? { |a| send("#{a}?", content_type) }
    end

    def pdf?(content_type)
      extra_content_types[:pdf].include? content_type
    end

    def find_all_by_content_types(types, *args)
      with_content_types(types) { find *args }
    end

    def with_content_types(types, &block)
      with_scope(:find => { :conditions => types_to_conditions(types).join(' OR ') }, &block)
    end

    def types_to_conditions(types)
      types.collect! { |t| '(' + send("#{t}_condition") + ')' }
    end
  end

  @@document_content_types = ['application/pdf', 'application/msword', 'text/plain']
  @@image_content_types = [:image]

  @@document_condition = send(:sanitize_sql, ['content_type IN (?)', @@document_content_types]).freeze
  cattr_reader :document_content_types, :image_content_types, :document_condition
  if Rails.env.test?
    has_attachment :storage => :file_system, :path_prefix => 'test/tmp/attachments', :content_type => [@@image_content_types, @@document_content_types].flatten, :thumbnails => { :lightbox => '490x390>', :list => '100x100', :display => '300x300' }, :max_size => 2.megabytes #generate print version after the fact
  elsif (s3_config_file = Rails.root.join('config', 'amazon_s3.yml')).exist?
    has_attachment :storage => :s3, :content_type => [Attachment.image_content_types, Attachment.document_content_types].flatten, :path_prefix => 'events/attachments', :thumbnails => { :lightbox => '490x390>', :list => '100x100', :display => '300x300' }, :bucket_name => AWS_S3_BUCKET_NAME
    self.attachment_options = AttachmentOptions.new(attachment_options)
  else
    has_attachment :storage => :file_system, :content_type => [@@image_content_types, @@document_content_types].flatten, :thumbnails => { :lightbox => '490x390>', :list => '100x100', :display => '300x300' }, :max_size => 2.megabytes 
  end
  validates_as_attachment
  def bucket_name
    attachment_options[:bucket_name] || @@bucket_name
  end

  [:video, :audio, :other, :pdf].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", content_type) }
  end

  belongs_to :user
  belongs_to :report
  belongs_to :event
  after_validation :set_event_id, :on => :create
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

  def clear_temp_paths
    @temp_paths.clear
  end

  def sanitize_input
    self.caption = scrub(self.caption) unless self.caption.nil?
  end

  attr_accessor :tag_depot

  attr_accessor :data_dump
  def data_dump
    @data_dump || 
      self.temp_data || 
      File.read( full_filename ) 
  rescue
    begin
      open(public_filename).read if public_filename
    rescue
      nil
    end
  end

  # copy tempfiles to presistent files because attachments stored as 
  # tempfiles are not guaranteed to persist if app server dies
  def make_local_copy
    self.temp_paths.map! do |tempfile_path|
      # gif files seem to come through as file handles -- attachment-fu bug?
      if tempfile_path.respond_to? :path
        tempfile_path = tempfile_path.path
      end
      tmp = Tempfile.new(File.basename(tempfile_path), Rails.root.join('tmp')) # specific folder please
      path = tmp.path
      tmp.close(true)
      FileUtils.cp tempfile_path, path
      path
    end
  end

  # undo make_local_copy (above) so that files used
  # in processing attachment are deleted (at some point)
  def move_to_temp_files
    self.temp_paths.map! do |file|
      tmp = Tempfile.new(random_tempfile_filename, Technoweenie::AttachmentFu.tempfile_path)
      path = tmp.path
      tmp.close(true)
      File.rename file, path
      path
    end
  end
end
