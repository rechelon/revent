namespace :reminder do
  desc "Remind hosts of events that have ended in the last 24 hours to send in a report"
  task :report do
    raise 'You need to set an environment varibale called SITE' if ENV['SITE'].nil? or ENV['SITE'].empty?
    load 'config/environment.rb'
    Site.current = ENV['SITE']
    site = Site.find_by_host Site.current
    events = site.events.find(:all, :conditions => ["events.end <= ? AND events.end > ?", Time.now, 1.day.ago])
    events.each do |e|
      next if e.reports.length > 0
      if e.calendar.triggers
        host_trigger = e.calendar.triggers.find_by_name("Report Host Reminder") 
        attendee_trigger = e.calendar.triggers.find_by_name("Report Attendee Reminder") 
      elsif e.calendar.site.triggers
        host_trigger = e.calendar.site.triggers.find_by_name("Report Host Reminder")
        attendee_trigger = e.calendar.site.triggers.find_by_name("Report Attendee Reminder")
      end
      if host_trigger
        TriggerMailer.deliver_trigger(host_trigger, e.host, e, e.calendar.site.host.hostname)
      end
      if attendee_trigger
        TriggerMailer.deliver_trigger(attendee_trigger, e.attendees, e, e.calendar.site.host.hostname)
        emails = e.attendees.map {|a| a.email}
        emails = emails.to_s
      end 
    end
  end
end
