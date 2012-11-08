# This defines a Resource for the campaign table in the DIA API
#
# note that the convenience functions att, links, multilinks, table
# must be defined in every subclass of DemocracyInActionResource
# so the code in the parent class can work properly
class DemocracyInActionCampaign <  DemocracyInActionResource
	# all attributes (columns) for this table.
	# stored as a hash table (name => 1)
	@@atts = {"key" => 1, "campaign_KEY"=>1, "organization_KEY"=>1, "chapter_KEY"=>1, "Last_Modified"=>1, "Date_Created"=>1, "Reference_Name"=>1, "Campaign_Title"=>1, "PRIVATE_Recent_Update"=>1, "Description"=>1, "More_Info"=>1, "Learn_More_Link"=>1, "photo_KEY"=>1, "rep_KEYS"=>1, "person_legislator_IDS"=>1, "exclude_person_legislator_IDS"=>1, "recipient_KEYS"=>1, "recipient_group_KEYS"=>1, "Suggested_Subject"=>1, "Subject_cannot_be_Edited"=>1, "Letter_cannot_be_Edited"=>1, "Letter_Salutation"=>1, "Suggested_Content"=>1, "Footer"=>1, "Hide_Message_Type_Options"=>1, "Allow_Emails"=>1, "Allow_Faxes"=>1, "Max_Number_Of_Emails"=>1, "Max_Number_Of_Faxes"=>1, "PRIVATE_Emails_Sent"=>1, "PRIVATE_Faxes_Sent"=>1, "Hide_Keep_Me_Informed"=>1, "Thank_You_Page_Text_or_HTML"=>1, "Success_Message"=>1, "Suppress_Automatic_Response_Email"=>1, "Spread_The_Word_Text"=>1, "Spread_The_Word_Redirect_Path"=>1, "exclude_rep_KEYS"=>1, "Status"=>1, "Request"=>1, "Required"=>1, "redirect_path"=>1, "email_trigger_KEYS"=>1, "groups_KEYS"=>1, "Automatically_add_to_Groups"=>1, "Default_Tracking_Code"=>1, "READONLY_Hit_Count"=>1, "Archive"=>1, "Brief_Summary"=>1, "Enable_Preview"=>1, "Preview_Text"=>1, "No_Recipient_Text"=>1, "Excluded_Recipient_Text"=>1, "Sponsorship_Link"=>1, "Roll_Call_Vote"=>1, "roll_call_ID"=>1, "Alternate_Description"=>1, "Alternate_Subject"=>1, "Alternate_Content"=>1, "Restricted_Regions"=>1, "Restricted_Districts"=>1, "Restricted_Text"=>1, "campaignid"=>1, "Template"=>1}

	# a list of all attributes that are links to another table
	# stored as a hash table (name => Class to link to)
	#@@links = {'organization'=>DemocracyInActionOrganization, 'chapter'=>DemocracyInActionChapter, 'photo'=>DemocracyInActionPhoto}
	@@links = {}

	# same as @@links, but these end with _KEYS and allow one to
	# link to multiple elements.
	#@@multilinks = {'rep'=>DemocracyInActionRep, 'recipient'=>DemocracyInActionRecipient, 'recipient_group'=>DemocracyInActionRecipientGroup, 'exclude_rep'=>DemocracyInActionExcludeRep, 'email_trigger'=>DemocracyInActionEmailTrigger, 'groups'=>DemocracyInActionGroups}
	@@multilinks = {}

	# return db table associated with this class, used for DIA API calls
  def DemocracyInActionCampaign.table
    'campaign'
  end

	# return hash of all valid columns, keys are column names
	def DemocracyInActionCampaign.atts
		@@atts
	end

	# return hash, keys are columns, values are classes they link to
	def DemocracyInActionCampaign.links
		@@links
	end

	# return hash, keys are columns, values are classes they link to
	# difference between links is that these can point to multiple elements
	def DemocracyInActionCampaign.multilinks
		@@multilinks
	end

	# optional to control the display in list
	# (only used in the test display code, you can ignore)
	def DemocracyInActionCampaign.columns
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
	end

end

