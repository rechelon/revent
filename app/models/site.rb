class Site < ActiveRecord::Base
  cattr_accessor :current
  has_one :config, :class_name => 'SiteConfig', :foreign_key => 'site_id'

  has_many :users
  #has_many :admins
  has_many :events, :through => :calendars
  has_many :triggers
  has_many :hostforms
  has_many :categories
  has_many :hosts

  has_many :calendars do
    def current
      proxy_target.detect {|c| c.current?}
    end
  end

  after_destroy :destroy_associations

  def to_label
    "#{host}"
  end  

  def self.clear_memcache
    Site.find(:all).each {|s| Cache.delete("site_for_host_#{s.host}")}
  end

  def clear_memcache
    Cache.delete("site_for_host_#{self.host}")
  end

  def sorted_calendars 
    @cals = self.calendars.find(:all, :order => "name")
    @all = @cals.detect {|c| c.permalink == "all"}
    @cals.unshift(@cals.delete(@all)) if @all
    @cals
  end

  def self.find_by_host(hostname)
    Host.find_by_hostname(hostname).site
  end

  def host
    return Host.current unless Host.current.nil?
    self.hosts.first unless self.hosts.blank?
  end
  
  def host=(host)
    if(host.respond_to? :hostname)
      self.hosts << host
      Host.current = host
    else
      h = Host.find_or_initialize_by_hostname({:hostname=>host.to_s})
      h.site = self
      self.hosts << h
      Host.current= h
    end
    Host.current
  end

  def theme
    self.host.theme 
  end

  def destroy_associations
    self.config.destroy
  end

end
