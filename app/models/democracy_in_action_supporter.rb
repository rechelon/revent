# This defines a Resource for the supporter table in the DIA API
#
# note that the convenience functions att, links, multilinks, table
# must be defined in every subclass of DemocracyInActionResource
# so the code in the parent class can work properly

# let's not depend on edge rails just yet, eh?
# hope this doesn't break anything, but for now the only guaranteed method is authenticate
class DemocracyInActionSupporter <  DemocracyInActionResource

  def self.authenticate(email, password)
    user = first(:conditions => "Email = '#{email}'")
    user && Digest::MD5.hexdigest(password) == user.Password ? user : nil
  end

  # no roles for now
  def roles
    @user ||= User.find_by_email(self.Email) || :false
    @user.is_a?(User) ? @user.roles : []
  end

  def admin?
    roles.any? {|r| 'admin' == r.title}
  end

  def events
    remote_events = [DemocracyInActionEvent.find(:all, :conditions => "supporter_KEY=#{key}")].flatten.compact
    events = DemocracyInActionObject.find_all_by_synced_type_and_key('Event', remote_events.collect {|e| e.key}).collect {|obj| obj.synced}
#    events.each {|e| e.dia_event = remote_events.select {|r| r.key == e.service_foreign_key}}
    return events
  end

  def events_attending
    links = api.get(:object => 'supporter_event', :condition => "supporter_KEY=#{key}")
    return [] if links.empty?
    remote_events_attending = [DemocracyInActionEvent.find(links.collect {|l| l['event_KEY']})].flatten.compact
    events_attending = DemocracyInActionObject.find_all_by_synced_type_and_key('Event', remote_events_attending.collect {|e| e.key}).collect {|obj| obj.synced}
#    events_attending.each {|e| e.dia_event = remote_events_attending.detect {|r| r.key == e.service_foreign_key}}
    return events_attending
  end

  # all attributes (columns) for this table.
  # stored as a hash table (name => 1)
  @@atts = {"key" => 1, "supporter_KEY"=>1, "organization_KEY"=>1, "chapter_KEY"=>1, "Last_Modified"=>1, "Date_Created"=>1, "Title"=>1, "First_Name"=>1, "MI"=>1, "Last_Name"=>1, "Suffix"=>1, "Email"=>1, "Password"=>1, "Receive_Email"=>1, "Email_Status"=>1, "Email_Preference"=>1, "Soft_Bounce_Count"=>1, "Hard_Bounce_Count"=>1, "Last_Bounce"=>1, "Receive_Phone_Blasts"=>1, "Phone"=>1, "Cell_Phone"=>1, "Phone_Provider"=>1, "Work_Phone"=>1, "Pager"=>1, "Home_Fax"=>1, "Work_Fax"=>1, "Street"=>1, "Street_2"=>1, "Street_3"=>1, "City"=>1, "State"=>1, "Zip"=>1, "PRIVATE_Zip_Plus_4"=>1, "County"=>1, "District"=>1, "Country"=>1, "Latitude"=>1, "Longitude"=>1, "Organization"=>1, "Department"=>1, "Occupation"=>1, "Instant_Messenger_Service"=>1, "Instant_Messenger_Name"=>1, "Web_Page"=>1, "Alternative_Email"=>1, "Other_Data_1"=>1, "Other_Data_2"=>1, "Other_Data_3"=>1, "Notes"=>1, "Source"=>1, "Source_Details"=>1, "Source_Tracking_Code"=>1, "Tracking_Code"=>1, "Status"=>1, "uid"=>1, "Timezone"=>1}

  # a list of all attributes that are links to another table
  # stored as a hash table (name => Class to link to)
# @@links = {'organization'=>DemocracyInActionOrganization, 'chapter'=>DemocracyInActionChapter}
  @@links = {}

  # same as @@links, but these end with _KEYS and allow one to
  # link to multiple elements.
  @@multilinks = {}

  # return db table associated with this class, used for DIA API calls
  def DemocracyInActionSupporter.table
    'supporter'
  end

  # return hash of all valid columns, keys are column names
  def DemocracyInActionSupporter.atts
    @@atts
  end

  # return hash, keys are columns, values are classes they link to
  def DemocracyInActionSupporter.links
    @@links
  end

  # return hash, keys are columns, values are classes they link to
  # difference between links is that these can point to multiple elements
  def DemocracyInActionSupporter.multilinks
    @@multilinks
  end

  # optional to control the display in list
  # (only used in the test display code, you can ignore)
  def DemocracyInActionSupporter.columns
    return self.atts.keys
  end

  # create a new instance with all the attributes set from a hash table
  def initialize(hash = nil)
      @data = Hash.new
      hash.reject {|k, v| !self.class.atts[k.to_s] }.each { |k, v| @data[k.to_s] = v.to_s } if hash
  end

end

