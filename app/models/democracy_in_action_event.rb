# This defines a Resource for the event table in the DIA API
#
# note that the convenience functions att, links, multilinks, table
# must be defined in every subclass of DemocracyInActionResource
# so the code in the parent class can work properly
class DemocracyInActionEvent <  DemocracyInActionResource
  def attendees
    links = api.get(:object => 'supporter_event', :condition => {"supporter_event.event_KEY=#{key}", 'column=supporter_KEY'})
    return [] if links.empty?
    [DemocracyInActionSupporter.find(links.collect {|l| l['supporter_KEY']})].flatten.compact
  end

  # all attributes (columns) for this table.
  # stored as a hash table (name => 1)
  @@atts = {"key" => 1, "event_KEY"=>1, "organization_KEY"=>1, "chapter_KEY"=>1, "national_event_KEY"=>1, "distributed_event_KEY"=>1, "supporter_KEY"=>1, "Event_Name"=>1, "Last_Modified"=>1, "Date_Created"=>1, "Description"=>1, "Address"=>1, "City"=>1, "State"=>1, "Zip"=>1, "Directions"=>1, "Header"=>1, "Footer"=>1, "PRIVATE_Zip_Plus_4"=>1, "Start"=>1, "End"=>1, "Recurrence_Frequency"=>1, "Recurrence_Interval"=>1, "Contact_Email"=>1, "Guests_allowed"=>1, "Maximum_Attendees"=>1, "Maximum_Waiting_List_Size"=>1, "Map_URL"=>1, "Status"=>1, "This_Event_Costs_Money"=>1, "Ticket_Price"=>1, "merchant_account_KEY"=>1, "Default_Tracking_Code"=>1, "redirect_path"=>1, "Request"=>1, "Required"=>1, "groups_KEYS"=>1, "Automatically_add_to_Groups"=>1, "Display_to_Chapters"=>1, "Request_Additional_Attendees"=>1, "One_Column_Layout"=>1, "event$email_trigger_KEYS"=>1, "waiting_list$email_trigger_KEYS"=>1, "upgrade_$email_trigger_KEYS"=>1, "Reminder_Status"=>1, "reminder_$email_trigger_KEYS"=>1, "Reminder_Hours"=>1, "Latitude"=>1, "Longitude"=>1, "Template"=>1}

  # a list of all attributes that are links to another table
  # stored as a hash table (name => Class to link to)
  #@@links = {'organization'=>DemocracyInActionOrganization, 'chapter'=>DemocracyInActionChapter, 'national_event'=>DemocracyInActionNationalEvent, 'distributed_event'=>DemocracyInActionDistributedEvent, 'supporter'=>DemocracyInActionSupporter, 'merchant_account'=>DemocracyInActionMerchantAccount}
  @@links = {}

  # same as @@links, but these end with _KEYS and allow one to
  # link to multiple elements.
  #@@multilinks = {'groups'=>DemocracyInActionGroups, 'email_trigger'=>DemocracyInActionEmailTrigger, 'email_trigger'=>DemocracyInActionEmailTrigger, 'email_trigger'=>DemocracyInActionEmailTrigger, 'email_trigger'=>DemocracyInActionEmailTrigger}
  @@multilinks = {}

  # return db table associated with this class, used for DIA API calls
  def DemocracyInActionEvent.table
    'event'
  end

  # return hash of all valid columns, keys are column names
  def DemocracyInActionEvent.atts
    @@atts
  end

  # return hash, keys are columns, values are classes they link to
  def DemocracyInActionEvent.links
    @@links
  end

  # return hash, keys are columns, values are classes they link to
  # difference between links is that these can point to multiple elements
  def DemocracyInActionEvent.multilinks
    @@multilinks
  end

  # optional to control the display in list
  # (only used in the test display code, you can ignore)
  def DemocracyInActionEvent.columns
    return self.atts.keys
  end

  # create a new instance with all the attributes set from a hash table
  def initialize(hash = nil)
    if hash == nil
      @data = Hash.new
    elsif bad_key = hash.keys.detect { |k| !self.class.atts[k.to_s] }
      raise 'Bad argument to initialize: ' + bad_key.to_s
    else
      @data = Hash.new
      hash.each { |k, v| @data[k.to_s] = v.to_s }
    end
    yield self if block_given?
  end

end

