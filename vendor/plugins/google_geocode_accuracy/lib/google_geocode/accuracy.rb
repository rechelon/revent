require 'google_geocode'
class GoogleGeocode::Accuracy < GoogleGeocode

  Location = Struct.new :google_geocode_location, :accuracy

  def parse_response(xml)
    location = super(xml)
    location_with_accuracy = Location.new
    location_with_accuracy.google_geocode_location = location
    location_with_accuracy.accuracy = xml.elements['/kml/Response/Placemark/AddressDetails'].attributes['Accuracy']
    return location_with_accuracy
  end
end

class GoogleGeocode::Accuracy::Location
  def method_missing(method)
    if google_geocode_location.respond_to?(method)
      google_geocode_location.send(method)
    else
      super
    end
  end
end
