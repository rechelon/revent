module Admin::EventsHelper
  def tags_column(event)
    event.tags.collect{|t| t.name}.join(', ')
  end

  def rsvps_column(event)
    event.rsvps.length
  end
  
  def reports_column(event)
    event.reports.length
  end

  def location_form_column(event, input_name)
    text_field_tag(input_name, event.location)
  end

  def state_form_column(event, input_name)
    select_tag(input_name, options_for_select(DemocracyInAction::Helpers.state_options_for_select(:include_provinces => true).unshift(['Not set', 0]), event.state))
  end
  
  def start_form_column(event, input_name)    
    datetime_select(input_name, :minute_step => 15, :twelve_hour => true)
  end
end
