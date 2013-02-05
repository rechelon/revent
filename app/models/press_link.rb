class PressLink < ActiveRecord::Base
  belongs_to :report
  before_save :add_http
  
  validate :verify_url
  def verify_url
    begin
      URI.parse(self.url)
    rescue URI::InvalidURIError
      errors.add(:url, 'The format of the URL is not valid.')
    end
  end
  
  def add_http
    # add 'http://' at beginning of url if not there
    if not self.url =~ /^https?:\/\/.*/
      self.url = "http://" + self.url
    end
  end
end

