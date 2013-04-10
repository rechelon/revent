module Admin::CalendarsHelper

  def suggested_event_start_form_column(record, input_name)
    datetime_select(:record, :event_start, :minute_step => 15, :twelve_hour => true, 
      :html => {'style' => 'padding-left:0 0 0 20px'})
  end

  def event_start_form_column(record, input_name)
    datetime_select(:record, :event_start, :minute_step => 15, :twelve_hour => true, 
      :html => {'style' => 'padding-left:0 0 0 20px'})
  end

  def event_end_form_column(record, input_name)
    html = radio_button_tag(:never, 1, (record.event_end ? false : true)) + "Never<br />"
    html += radio_button_tag(:never, 0, (record.event_end ? true : false)) + "Until "      
    html += datetime_select(:record, :event_end, :minute_step => 15, :twelve_hour => true)
  end

  def permalink_column(calendar)
    link_to 'Preview', :controller => '/events', :permalink => calendar.permalink 
  end

  def name_column(calendar)
    link_to calendar.name, :controller => '/admin/calendars', :action => :edit, :id => calendar.id
  end

  def past_counts(calendar)
    Event.with_past do
      counts(calendar)
    end
  end

  def upcoming_counts(calendar)
   Event.with_upcoming do
     counts(calendar)
    end
  end

  def rsvp_count(calendar)
    calendar.events(:include => :rsvps).inject(0) do |count, event|
      count += event.rsvps.length
    end
  end

  def report_count(calendar)
    calendar.reports.length
  end
  
  def events_with_reports_count(calendar)
    calendar.events.with_reports.length
  end
  
  def letter_script_form_column(record, input_name)
    text_area :record, :letter_script, 'rows' => 20, :cols => 65, :name => input_name
  end
  
  def call_script_form_column(record, input_name)
    text_area :record, :call_script, 'rows' => 20, :cols => 65, :name => input_name
  end

  def permalink_form_column(record, input_name)
    if record.permalink
      record.permalink
    else
      text_field(:record, :permalink)
    end
  end
  
  def site_id_form_column(record, input_name)
    return Site.find(record.site_id).host if record.site_id
    record.site_id = Site.current.id
    text_field(:record, :site_id)
  end

  def signup_redirect_form_column(record, input_name)
    input :record, :signup_redirect, :size => 50, :class => 'text-input'
  end
  
  def options_for_association_conditions(association)
    if association.name == :hostform
      ['hostforms.site_id = ?', Site.current.id]
    else
      super
    end
  end
end
