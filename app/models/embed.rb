class Embed < ActiveRecord::Base
  belongs_to :report
  validates_presence_of :html

  before_create :extract_youtube_video_id
  def extract_youtube_video_id
    require 'nokogiri'
    doc = Nokogiri::HTML(html)
    iframes = doc.search('iframe')
    return unless iframes.count > 0
    iframe_src = iframes[0].attributes["src"].value
    youtube_video_id = iframe_src.split('/').last.split('&').first
    self.youtube_video_id ||= youtube_video_id
  end
  
  def youtube_thumbnail_url
    if self.youtube_video_id
      "http://i.ytimg.com/vi/#{self.youtube_video_id}/default.jpg"
    end
  end
  
  def youtube_video_url
    if self.youtube_video_id
      "http://www.youtube.com/watch?v=#{self.youtube_video_id}"
    end
  end

  attr_accessor :tag_depot
end
