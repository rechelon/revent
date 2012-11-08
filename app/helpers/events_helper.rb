module EventsHelper
  def event_date_range(event)
    if event.time_tbd?
      html = "#{event.start? ? event.start.strftime('%B %e, %Y - Time TBD') : '?'}"
    else
      html = "#{event.start? ? event.start.strftime('%B %e, %Y  %I:%M%p') : '?'}"
    end
    
    return html if event.supress_end_time?
    #append end time
    if event.end && !event.time_tbd?
      event_end = (event.start.beginning_of_day == event.end.beginning_of_day) ? 
        event.end.strftime('%I:%M%p') : event.end.strftime('%B %e, %Y  %I:%M%p')
      html << " to #{event_end}"
    end
    if(event.end && event.time_tbd? && 
    !event.start.beginning_of_day == event.end.beginning_of_day)
      event.end.strftime('%B %e, %Y')
      html << " to #{event_end}"
    end
    html
  end

end
