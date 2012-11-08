class Host < ActiveRecord::Base
  belongs_to :site
  before_validation :downcase_hostname
  validates_uniqueness_of :hostname
  cattr_accessor :current
  SHORTLINE_CLI = "short"

  def self.current= host
    if host.respond_to? :hostname
      @@current = host
      return @@current
    end
    @@current = Host.find_or_initialize_by_hostname(host.to_s)
  end

  def self.generate_shortline_script file_path, ip_address = nil
    lines = []

    lines.push("#!/bin/bash")
    lines.push("")
    self.find(:all).each do |h|
      if ip_address.nil?
        lines.push(SHORTLINE_CLI + " add receiver revent_" + h.hostname + " " + h.hostname)
      else
        lines.push(SHORTLINE_CLI + " add receiver revent_" + h.hostname + " " + h.hostname + " -i " + ip_address)
      end
    end
    f = File.open(file_path, "w")
    f.write(lines.join("\n"))
    f.close()
    File.chmod(0775, file_path)
    return true
  end

  def fb_login_enabled?
    !fb_app_id.blank? && !fb_app_secret.blank?
  end

  def google_login_enabled?
    !google_oauth_key.blank? && !google_oauth_secret.blank?
  end

  def twitter_login_enabled?
    !twitter_oauth_key.blank? && !twitter_oauth_secret.blank?
  end

  def google_maps_api_key
    read_attribute(:google_maps_api_key) || Site.current.config.google_maps_api_key
  end

  protected
    def downcase_hostname
      self.hostname = hostname.to_s.downcase
    end
end
