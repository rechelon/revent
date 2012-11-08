Event.class_eval do
  def sync_to_democracy_in_action
  end
  def geocode
  end
end

User.class_eval do
  def sync_to_democracy_in_action
  end
end

Site.current = Site.find_by_host("actions.energyactioncoalition.org")
calendar = Site.current.calendars.find_by_permalink("fossilfools")
DemocracyInActionEvent.find(:all).each do |dia_event|
  Event.create_from_democracy_in_action_event(dia_event, calendar)
end
