class Video < ActiveRecord::Base
  attr_accessor :embed_code

  belongs_to :report
  belongs_to :user

  before_create :extract_video_id
  def extract_video_id
    require 'nokogiri'
    doc = Nokogiri::HTML(embed_code)
    case self.service
    when "YouTube"
      iframes = doc.search('iframe')
      return unless iframes.count > 0
      iframe_src = iframes[0].attributes["src"].value
      youtube_video_id = iframe_src.split('/').last.split('&').first
      self.vid ||= youtube_video_id
    end
  end

  def display
    case self.service
    when "YouTube"
      return "<iframe width=\"420\" height=\"315\" src=\"http://www.youtube.com/embed/"+self.vid+"\" frameborder=\"0\" allowfullscreen></iframe>"
    end
  end

end
