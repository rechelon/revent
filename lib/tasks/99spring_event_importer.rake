NAME_FIELD = 'Event Name'
DESCRIPTION_FIELD = 'Long Description'
SHORT_DESCRIPTION_FIELD = 'Short Description'
DIRECTIONS_FIELD = 'Directions'
LOCATION_FIELD = 'Address'
CITY_FIELD = 'City'
STATE_FIELD = 'State'
POSTAL_CODE_FIELD = 'Postal Code'
FB_EVENT_ID_FIELD = 'FB Event ID'
START_DATE_FIELD = 'Start Date'
START_TIME_FIELD = 'Start Time'
END_DATE_FIELD = 'End Date'
END_TIME_FIELD = 'End Time'
HOST_NAME_FIELD = 'Host Name'
HOST_FIRST_NAME_FIELD = 'Host First Name'
HOST_LAST_NAME_FIELD = 'Host Last Name'
HOST_EMAIL_FIELD = 'Host Email'
HOST_PHONE_FIELD = 'Host Phone'
EVENT_CUSTOM_ATTRIBUTE_FIELDS = {
  'sponsor_union' => 'Sponsor Union',
  'sponsor_local' => 'Sponsor Local',
  'sponsor_other' => 'Sponsor Other'
}

namespace :'99spring' do
  desc "Import 99 Spring events"
  task :import_events do
    raise 'You need to set an environment varibale called HOST' if ENV['HOST'].nil? or ENV['HOST'].empty?
    raise 'You need to set a variable called FILE, that file should be located in tmp/' if ENV['FILE'].nil? or ENV['FILE'].empty?
    raise 'You need to set an environment varibale called CALENDAR' if ENV['CALENDAR'].nil? or ENV['CALENDAR'].empty?

    require 'fastercsv'
    load 'config/environment.rb'

    Site.current = Site.find_by_host ENV['HOST'] 
    Host.current = ENV['HOST']
    c = Calendar.find_by_permalink ENV['CALENDAR']

    #instantiate good csv file
    winners = FasterCSV::Table.new []
    #insantiate bad csv file
    rejects = FasterCSV::Table.new []


    FasterCSV.foreach(Rails.root.join("tmp", ENV['FILE']), {:headers=>true}) do |row|

      if row[START_DATE_FIELD].blank?
        puts 'no start date'
        rejects << row
        next
      end

      start_date = row[START_DATE_FIELD]

      if row[START_TIME_FIELD].blank?
        start_time = '8:00am'
        end_time = '9:00pm'
      else
        start_time = row[START_TIME_FIELD]
      end

      begin
        print "start date: #{start_date}"
        print "start time: #{start_time}"
        start_date = "#{start_date} #{start_time}".to_datetime
        print "start datetime: #{start_date}"
      rescue Exception=>e
        print "Couldnt process datetime; rejecting"
        rejects << row
        next
      end
      
      if row[END_DATE_FIELD].blank?
        end_date = row[START_DATE_FIELD]
      else
        end_date = row[END_DATE_FIELD]
      end
      
      if row[END_TIME_FIELD].blank?
        end_date = "#{end_date} #{start_time}"
        end_date = end_date.to_datetime + 2.hours
      else
        end_date = "#{end_time} #{end_date}"
      end

      #user
      if(row[HOST_EMAIL_FIELD].blank?)
        rejects << row
        puts 'bad user'
        puts row.inspect
        puts 'NO EMAIL'
        next
      end
      
      u = User.find_or_create_by_email row[HOST_EMAIL_FIELD]
      
      if !row[HOST_NAME_FIELD].blank?
        first_name,last_name = row[HOST_NAME_FIELD].split /\/(?=[^\/]+(?: |$))| /,2 
      elsif !row[HOST_FIRST_NAME_FIELD].blank? || !row[HOST_LAST_NAME_FIELD].blank?
        first_name = row[HOST_FIRST_NAME_FIELD]
        last_name = row[HOST_LAST_NAME_FIELD]
      else
        rejects << row
        puts 'bad user'
        puts row.inspect
        puts 'NO NAME'
        next      
      end
      
      u.attributes = {
        :first_name => first_name,
        :last_name => last_name,
        :show_phone_on_host_profile => false,
        :site => Site.current
      }
      u.phone = row[HOST_PHONE_FIELD] unless row[HOST_PHONE_FIELD].blank?
      
      if !u.valid?
        rejects << row
        puts 'bad user'
        puts row.inspect
        puts u.errors.inspect
        next
      else
        puts 'good user'
        u.save!
      end
      
      #event
      e = Event.new
      e.attributes = { 
        :calendar_id => c.id,
        :name => row[NAME_FIELD],
        :description => row[DESCRIPTION_FIELD],
        :short_description => row[SHORT_DESCRIPTION_FIELD],
        :directions => row[DIRECTIONS_FIELD],
        :location=> row[LOCATION_FIELD],
        :city => row[CITY_FIELD],
        :state => row[STATE_FIELD],
        :postal_code => row[POSTAL_CODE_FIELD],
        :fb_id => row[FB_EVENT_ID_FIELD],
        :start => start_date,
        :end => end_date,
        :host_id => u.id
      }
      e.locationless = true unless(row[LOCATION_FIELD] && row[CITY_FIELD] && row[STATE_FIELD] && row[POSTAL_CODE_FIELD])      
      e.suppress_email = true

      if !e.valid?
        puts 'bad event'
        puts row.inspect
        puts e.errors.full_messages.inspect        
        rejects << row
#TODO: destroy user if user has taken no other actions
#        u.destroy
        next
      else
        puts 'good event'
        winners << row
        e.save!
      end
      
      #custom attributes
      EVENT_CUSTOM_ATTRIBUTE_FIELDS.each do |custom_field_name, csv_field_name|
        unless row[csv_field_name].nil?
          e.custom_attributes.create(:name=>custom_field_name, :value => row[csv_field_name])
        end
      end 
    end
    
    winners_file = File.new('winners.csv', 'w+')
    winners_file << winners.to_csv
    winners_file.close
    rejects_file = File.new('rejects.csv', 'w+')
    rejects_file << rejects.to_csv
    rejects_file.close
    puts("#{winners.length} events validated")
    puts("#{rejects.length} events rejected")
  end
end
