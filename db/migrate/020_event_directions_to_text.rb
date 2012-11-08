class EventDirectionsToText < ActiveRecord::Migration
  def self.up
    transaction do
      change_column :events, :directions, :text
      return true if Event.count == 0
      return unless File.exists?(File.join(RAILS_ROOT,'config','democracyinaction-config.yml'))
      opts = YAML.load_file(File.join(RAILS_ROOT,'config','democracyinaction-config.yml'))
#      require 'DIA_API_Simple'
      require 'democracyinaction'
      api = DIA_API_Simple.new opts
      events = api.get('event', 'column' => 'Directions')
      events.each do |e|
        my_event = Event.find_by_service_foreign_key(e['event_KEY'])
        my_event.update_attribute(:directions, e['Directions']) if my_event
      end
    end
  end

  def self.down
  end
end
