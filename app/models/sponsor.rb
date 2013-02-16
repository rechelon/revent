class Sponsor < ActiveRecord::Base
  belongs_to :site
  has_and_belongs_to_many :events
  has_and_belongs_to_many :users
  has_many :user_permissions, :conditions => 'name = "sponsor_admin"', :foreign_key => 'value'
  has_many :admins, :through => :user_permissions, :source => :user
  has_and_belongs_to_many :reports

  validates_uniqueness_of   :partner_code, :scope => :site_id, :case_sensitive => false

  before_create :set_site_id

  def as_json o={}
    super({
      :except => [:site_id]
    }.merge o)
  end

  def set_site_id
    self.site_id ||= Site.current.id if Site.current
  end


end
