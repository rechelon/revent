xml.instruct! :xml, :version=>"1.0"
xml.rss (:version => "2.0", "xmlns:geo" => "http://www.w3.org/2003/01/geo/wgs84_pos#", "xmlns:ymaps" => "http://api.maps.yahoo.com/Maps/V1/AnnotatedMaps.xsd") {
  xml.channel {
    xml.title(@calendar.name)
    xml.link(calendar_home_url(:permalink => @calendar.permalink))
    xml.description("Events enhanced with location info")
    xml.language('en-us')
    for event in @events
      xml.item do
        xml.title do
          xml.cdata!(event.name)
        end
        xml.description do
          xml.cdata!(event.description)
        end
        #xml.author :name do
        #  xml.text! event.host.name
        #end
        xml.pubDate(event.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link( "http://"+Host.current.hostname+url_for(:permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event.id))
        xml.guid( "http://"+Host.current.hostname+url_for(:permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event.id))
        unless event.latitude.nil?
          xml.geo :lat do
            xml.text! event.latitude.to_s
          end
        end
        unless event.longitude.nil?
          xml.geo :long do
            xml.text! event.longitude.to_s
          end
        end
      end
    end
  }
}
