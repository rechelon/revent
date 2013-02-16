class Theme < ActiveRecord::Base
  CONTENT_TOKEN = "{{content}}"
  THEME_ELEMENT_NAMES = %w(body head site_name site_title site_description event_form_after_info report_form_additional_fields profile_form_additional_fields event_form_time_tbd_override event_form_privacy_override event_form_info_beginning event_alias)
  
  belongs_to :site
  has_many :calendars
  has_many :elements, :class_name => 'ThemeElement', :dependent => :destroy
  
  THEME_ELEMENT_NAMES.each do |meth|
    define_method(meth) do
      self[meth] = ThemeElement.find_by_theme_id_and_name self.id, meth unless self[meth]
      if self[meth]
        self[meth].markdown
      else
        nil
      end
    end
    define_method(meth+"=") do |markdown|
      self.send(meth)
      if self[meth]
        self[meth].markdown = markdown
        self[meth].save
      else
        self[meth] = ThemeElement.create(:theme_id => self.id, :name => meth, :markdown => markdown)
      end
    end
  end

  def as_json o={}
    super({
      :include => [:elements]
    }.merge o)
  end

  def pre_content
    parse_body_into_content_areas unless @pre_content
    @pre_content
  end 

  def post_content
    parse_body_into_content_areas unless @post_content
    @post_content
  end 

  def parse_body_into_content_areas
    @pre_content, @post_content = body.split(CONTENT_TOKEN, 2)
  end

end
