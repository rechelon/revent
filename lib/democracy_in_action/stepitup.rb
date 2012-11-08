module DemocracyInAction
  module Stepitup
    def clear_deleted_events(calendar_id = nil)
      events = Event.find(:all, :conditions => "service_foreign_key != 0")
      events.each do |e|
        e.destroy if e.service_foreign_key && !DemocracyInActionEvent.find(e.service_foreign_key)
      end
    end

    DiaLoadResult = Struct.new(:imported, :unknown, :inaccurate)
    def self.load_from_dia(id, *args)
      cal = find(id)
      return unless cal
      #TODO: use DemocracyInActionEvent
      options = args.last.is_a?(Hash) ? args.pop : {}
      opts = YAML.load_file(File.join(RAILS_ROOT,'config','democracyinaction-config.yml'))
#        require 'DIA_API_Simple'
      require 'democracyinaction'
      api = DIA_API_Simple.new opts
      events = api.get('event', options[:options_for_dia] || {})
      result = DiaLoadResult.new 0, 0, 0
      return result if events.empty?

      gmaps = Cartographer::Header.new
      if gmaps.has_key? options[:host]
        application_id = gmaps.value_for options[:host]
        require 'google_geocode'
        gg = GoogleGeocode::Accuracy.new application_id
      end

      events.each do |e|
        my_event = Event.find_or_initialize_by_service_foreign_key(e['event_KEY'])
        next if !my_event.new_record? &&
          my_event.name         == e['Event_Name'] &&
          my_event.description  == e['Description'] &&
          my_event.location     == e['Address'] &&
          my_event.city         == e['City'] &&
          my_event.state        == e['State'] &&
          my_event.postal_code  == e['Zip'] &&
          my_event.start        == e['Start'].to_time(:local) &&
          my_event.end          == e['End'].to_time(:local) &&
          my_event.directions   == e['Directions']

        my_event.calendar_id = id
        my_event.name = e['Event_Name']
        my_event.description = e['Description']
        my_event.location = e['Address']
        my_event.city = e['City']
        my_event.state = e['State']
        my_event.postal_code = e['Zip']
        my_event.start = e['Start']
        my_event.end = e['End']
        my_event.directions = e['Directions']

        if gg
          begin
            location = gg.locate my_event.address_for_geocode
            if location.accuracy.to_i < 7
              result.inaccurate = result.inaccurate + 1
            else
              my_event.latitude = location.latitude
              my_event.longitude = location.longitude
            end
          rescue GoogleGeocode::AddressError => error
            result.unknown = result.unknown + 1
          end
        end

        my_event.perform_remote_update = false
        begin
          my_event.save!
        rescue ActiveRecord::RecordInvalid => err
          UserMailer.deliver_invalid(my_event, err)
          my_event.save(false)
        end

        if e['Default_Tracking_Code']
          tag = Tag.find_or_create_by_name e['Default_Tracking_Code']
          my_event.tags << tag
        end
      end
      result.imported = events.length

      return result
    end
  end
end
