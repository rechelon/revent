namespace :tarsands do
  desc "Import Tarsands Action events"
  task :import_events do
    raise 'You need to set an environment varibale called SITE' if ENV['SITE'].nil? or ENV['SITE'].empty?
    raise 'You need to set a variable called FILE, that file should be located in tmp/' if ENV['FILE'].nil? or ENV['FILE'].empty?
    raise 'You need to set an environment varibale called CALENDAR' if ENV['CALENDAR'].nil? or ENV['CALENDAR'].empty?

    require 'fastercsv'
    load 'config/environment.rb'

    Site.current = Site.find_by_host ENV['SITE'] 
    Host.current = ENV['SITE']
    c = Calendar.find_by_permalink ENV['CALENDAR']

    #instantiate good csv file
    winners = FasterCSV::Table.new []
    #insantiate bad csv file
    rejects = FasterCSV::Table.new []


    FasterCSV.foreach(Rails.root.join("tmp", ENV['FILE']), {:headers=>true}) do |row|

      if row['start_date'].blank?
        puts 'no start date'
        rejects << row
        next
      end

      start_date = row['start_date']

      if row['start_time'].blank?
        start_time = '8:00am'
        end_time = '9:00pm'
      end

      begin
        start_date = "#{start_time} #{start_date}".to_datetime
      rescue Exception=>e
        print "Couldnt process datetime; rejecting"
        rejects << row
        next
      end
      
      if row['end_date'].blank?
        end_date = row['start_date']
      else
        end_date = row['end_date']
      end
      
      if row['end_time'].blank?
        end_date = "#{start_time} #{end_date}"
        end_date = end_date.to_datetime + 2.hours
      else
        end_date = "#{end_time} #{end_date}"
      end

      #user
      if(row['host_email'].blank?)
        rejects << row
        puts 'bad user'
        puts row.inspect
        puts 'NO EMAIL'
        next
      end
      
      u = User.find_or_create_by_email row['host_email']
      
      if !row['host_name'].blank?
        first_name,last_name = row['host_name'].split /\/(?=[^\/]+(?: |$))| /,2 
      elsif !row['host_first_name'].blank? || !row['host_last_name'].blank?
        first_name = row['host_first_name']
        last_name = row['host_last_name']
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
      u.phone = row['host_phone'] unless row['host_phone'].blank?
      
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
        :name => row['name'],
        :description => row['description'],
        :short_description => row['short_description'],
        :location=> row['address'],
        :city => row['city'],
        :state => row['state'],
        :postal_code => row['zip'],
        :fb_id => row['fb_id'],
        :start => start_date,
        :end => end_date,
#        :private => row['public'].blank?,
        :host_id => u.id
      }
      e.locationless = true unless(row['address'] && row['city'] && row['state'] && row['zip'])      
      e.suppress_email = true

      if !e.valid?
        puts 'bad event'
        puts row.inspect
        puts e.errors.full_messages.inspect        
        rejects << row
        u.destroy
        next
      else
        puts 'good event'
        winners << row
        e.save!
      end
      
      #custom attributes
      e.custom_attributes.create(:name=>'sponsor_union', :value => row['sponsor_union']) unless row['sponsor_union'].nil?
      e.custom_attributes.create(:name=>'sponsor_local', :value => row['sponsor_local']) unless row['sponsor_local'].nil?
      e.custom_attributes.create(:name=>'sponsor_other', :value => row['sponsor_other']) unless row['sponsor_other'].nil?
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
def convert_ms_crap( string )
  string.gsub! "\342\200\230", "'"
  string.gsub! "\342\200\231", "'"
  string.gsub! "\342\200\234", '"'
  string.gsub! "\342\200\235", '"'
  string
end
