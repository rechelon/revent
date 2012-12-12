module ReportsHelper
  def primary_image_for(event)
    image = event.reports.collect {|r| r.attachments}.flatten.detect {|a| a.image? && a.primary}
    image ||= event.reports.collect {|r| r.attachments}.flatten.detect {|a| a.image? }
    image ? image_tag(image.public_filename(:list)) : nil
  end

  def events_select
    @calendar.events.reportable.newer_than(@calendar.past_event_cutoff - 60.days).find_all(:order=>"state,city").collect {|e| [truncate("#{e.state || e.country} - #{e.city} - #{e.start.strftime('%m/%d/%y')}: #{e.name}",:length => 70), e.id]}
  end
end
