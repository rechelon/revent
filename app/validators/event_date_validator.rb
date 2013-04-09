class EventDateValidator < ActiveModel::Validator

  def validate event
    if (event.start && event.end) && (event.start > event.end)
      event.errors.add :start, "date must be before end date"
    end
    calendar = event.calendar
    if (event.start && calendar.event_start) && (event.start < calendar.event_start.at_beginning_of_day)
      message = (calendar.event_end && (calendar.event_start.to_date == calendar.event_end.to_date)) ? "on" : "on or after"
      event.errors.add :start, "must be #{message} #{calendar.event_start.strftime('%B %e, %Y')}"
    end
    if (event.end && calendar.event_end) && (event.end > (calendar.event_end + 1.day).at_beginning_of_day)
      message = (calendar.event_start.to_date == calendar.event_end.to_date) ? "on" : "on or before"
      event.errors.add :end, "must be #{message} #{calendar.event_end.strftime('%B %e, %Y')}"
    end
  end

end
