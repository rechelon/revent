class Supporter < ActiveRecord::Base
  geocoded_by :address_for_geocode
  before_save :geocode
  
  def self.near_event(event)
    gk = event.calendar.get_supporter_group_keys
    likes = gk.map {|key| 'dia_group_keys LIKE "%'+key+'%"'}
    likes = likes.join(' or ')
    likes = 'true' if likes.empty?
    likes = "( "+likes+" )"
    
    near(event.postal_code, Site.current.config.nearby_supporter_radius).find(:all, :conditions => likes)
  end

  def self.create_supporters_from_dia_group(group_key)
    api = DemocracyInAction::API.new(Site.current.config.salsa_api_keys)
    api.authenticate
    supporter_keys =  api.get(:object => 'supporter_groups', :condition => 'supporter_groups.groups_KEY='+group_key).map {|g| g['supporter_KEY']}
    return if supporter_keys.empty?
    supporters = []
    supporter_keys.each do |key|
      supporters << api.supporter.get(:key => key)
    end
    supporters.each do |supporter|
      s = Supporter.build_from_dia_record(supporter)
      s.add_group_key group_key
      s.save
    end
  end
 
  def self.build_from_dia_record(supporter)
    s = self.find_or_initialize_by_dia_supporter_id supporter['supporter_KEY']
    s.first_name = supporter['First_Name']
    s.last_name = supporter['Last_Name']
    s.email = supporter['Email']
    s.street = supporter['Street']
    s.state = supporter['State']
    s.postal_code = supporter['Zip']
    s
  end

  def name 
    self.first_name + ' ' + self.last_name
  end

  def add_group_key(group_key)
    self.dia_group_keys ||= ''
    keys = self.dia_group_keys.split(',')
    keys<< group_key
    keys.uniq!
    self.dia_group_keys = keys.join(',')
  end

  def address_for_geocode
    [street, city, state, postal_code].compact.join(', ').gsub /\n/, ' '
  end
  alias address address_for_geocode

  private
  def geocode
    if (geo = Geocoder.search(address_for_geocode)).count == 1
      self.latitude = geo[0].coordinates[0]
      self.longitude = geo[0].coordinates[1]
      self.precision = geo[0].precision
    elsif self.postal_code =~ /^\d{5}(-\d{4})?$/ and (zip = ZipCode.find_by_zip(self.postal_code))
      self.latitude, self.longitude = zip.latitude, zip.longitude if zip
      self.precision = 'zip'
    elsif self.postal_code   # handle US postal codes not in ZipCode table and Canadian postal
      if (geo = Geocoder.search(self.postal_code)).count == 1
        self.latitude = geo[0].coordinates[0]
        self.longitude = geo[0].coordinates[1]
        self.precision = geo[0].precision
      end
    end
  end

end
