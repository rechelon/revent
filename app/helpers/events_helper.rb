module EventsHelper
  def event_date_range(event)
    event_start = event.start
    event_end = event.end
    #unless event.time_zone.nil?
    #  event_start = event_start.in_time_zone(event.time_zone.name) unless event_start.nil?
    #  event_end = event_end.in_time_zone(event.time_zone.name) unless event_end.nil?
    #end
    if event.time_tbd?
      html = "#{event.start? ? event_start.strftime('%B %e, %Y - Time TBD') : '?'}"
    else
      html = "#{event.start? ? event_start.strftime('%B %e, %Y  %I:%M%p') : '?'}"
    end
    
    return html if event.supress_end_time?
    #append end time
    if event_end && !event.time_tbd?
      event_end_string = (event_start.beginning_of_day == event_end.beginning_of_day) ? 
        event_end.strftime('%I:%M%p') : event_end.strftime('%B %e, %Y  %I:%M%p')
      html << " to #{event_end_string}"
    end
    if(event_end && event.time_tbd? && 
    !event_start.beginning_of_day == event_end.beginning_of_day)
      event_end.strftime('%B %e, %Y')
      html << " to #{event_end_string}"
    end
    html
  end

end
