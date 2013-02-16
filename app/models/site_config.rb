class SiteConfig < ActiveRecord::Base
  belongs_to :site
  
  serialize :icon_upcoming
  serialize :icon_past
  serialize :icon_worksite

  attr_accessor :custom_attributes_split, :required_custom_attributes_split, :custom_event_attributes_split, :custom_attributes_options_deserialized, :custom_event_options_deserialized

  def salsa_enabled?
    !salsa_node.blank? && !salsa_user.blank? && !salsa_pass.blank?
  end

  def salsa_api_keys
    { :username => salsa_user,
      :password => salsa_pass,
      :node => salsa_node }
  end

  def salsa_node
    self.read_attribute(:salsa_node).to_sym unless self.read_attribute(:salsa_node).blank?
  end

  def google_maps_api_key
    DEFAULT_GOOGLE_MAPS_API_KEY
  end

  def icon_upcoming
    self.read_attribute(:icon_upcoming) || DEFAULT_ICON_UPCOMING
  end
  
  def icon_past
    self.read_attribute(:icon_past) || DEFAULT_ICON_PAST
  end
  
  def icon_worksite
    self.read_attribute(:icon_worksite) || DEFAULT_ICON_WORKSITE
  end
 
  def custom_attributes
    return [] if self.custom_attributes_raw.nil?
    return self.custom_attributes_split unless self.custom_attributes_split.nil?
    self.custom_attributes_split = self.custom_attributes_raw.split(',')
    self.custom_attributes_split
  end

  def required_custom_attributes
    return [] if self.required_custom_attributes_raw.nil?
    return self.required_custom_attributes_split unless self.required_custom_attributes_split.nil?
    self.required_custom_attributes_split = self.required_custom_attributes_raw.split(',')
    self.required_custom_attributes_split
  end

  def required_custom_attributes= options
    self.required_custom_attributes_split = options
    self.required_custom_attributes_raw = options.join(',')
  end

  def custom_event_attributes
    return [] if self.custom_event_attributes_raw.nil?
    return self.custom_event_attributes_split unless self.custom_event_attributes_split.nil?
    self.custom_event_attributes_split = self.custom_event_attributes_raw.split(',')
    self.custom_event_attributes_split
  end

  def custom_attributes_options
    return {} if self.custom_attributes_options_raw.nil?
    return self.custom_attributes_options_deserialized unless self.custom_attributes_options_deserialized.nil?
    self.custom_attributes_options_deserialized = Marshal::load self.custom_attributes_options_raw
    self.custom_attributes_options_deserialized
  end

  def custom_event_options
    return {} if self.custom_event_options_raw.nil?
    return self.custom_event_options_deserialized unless self.custom_event_options_deserialized.nil?
    self.custom_event_options_deserialized = Marshal::load self.custom_event_options_raw
    self.custom_event_options_deserialized
  end

  def as_json o={}
    o ||= {}
    {
      'custom_attributes'=> self.custom_attributes,
      'custom_attributes_options' => self.custom_attributes_options,
      'custom_event_attributes' => self.custom_event_attributes,
      'custom_event_options' => self.custom_event_options
    }.merge o
  end 
end
