namespace :onesky do
  desc "Import 10/10/10 events"
  task :import do
    raise 'You need to set an environment varibale called SITE' if ENV['SITE'].nil? or ENV['SITE'].empty?
    raise 'You need to set a variable called FILE' if ENV['FILE'].nil? or ENV['FILE'].empty?
    require 'fastercsv'
    load 'config/environment.rb'
    Site.current = Site.find_by_host ENV['SITE'] 
    Host.current = ENV['SITE']
    c = Calendar.find_by_permalink '1010'
    FasterCSV.foreach(RAILS_ROOT + "/lib/" + ENV['FILE'], {:headers=>true}) do |row|
      zip = row['Postal Code']
      next if zip.nil? || zip.length < 4
      zip = '0'+zip if zip.length == 4
      name = convert_ms_crap(row['Action Title'])
      description = convert_ms_crap(row['Action Description'])
      e = Event.find_or_create_by_name row['Action Title']
      e.attributes = { 
        :start => Time.mktime(2010, 10, 10, 14),  
        :calendar_id => c.id,
        :name => name, 
        :description => description,
        :custom_1 => row['Action Page URL'],
        :city => row['City'],
        :state => row['Province'],
        :postal_code => row['Postal Code']
      } 
      e.save(false)
      e.save! if e.valid?
      puts e.inspect
    end    
  end
end
def convert_ms_crap( string )
  string.gsub! "\342\200\230", "'"
  string.gsub! "\342\200\231", "'"
  string.gsub! "\342\200\234", '"'
  string.gsub! "\342\200\235", '"'
  string
end
