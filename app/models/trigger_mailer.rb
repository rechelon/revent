class TriggerMailer < ActionMailer::Base
  def trigger(trigger, recipient, event, host=nil)
    host ||= Site.current.host.hostname
    sub_tokens(trigger, event, host, recipient)
    if recipient.respond_to? :inject
      recipients = recipient.map {|r| "#{r.email}"}
    else
      recipients = "#{recipient.email}"
    end
    @email_plain = trigger.email_plain
    @email_html => trigger.email_html}
    mail(:to => recipients,
         :subject => trigger.subject,
         :from => "#{trigger.from_name} <#{trigger.from}>",
         :bcc => trigger.bcc,
         :'reply-to' => trigger.reply_to)
         
  end

  protected
  def sub_tokens(trigger, event, host, recipient)                          
    tokens = {}
    tokens['[EVENT_NAME]'] = event.name || 'this event'
    tokens['[EVENT_CITY]'] = event.city
    tokens['[EVENT_STATE]'] = event.state
    tokens['[EVENT_ADDRESS]'] = event.location
    tokens['[EVENT_START_DATE]'] = event.start_date
    tokens['[EVENT_START_TIME]'] = event.start_time
    tokens['[HOST_NAME]'] = event.host.name || 'the event host'
    tokens['[HOST_FIRST_NAME]'] = event.host.first_name || 'the event host'
    tokens['[HOST_LAST_NAME]'] = event.host.last_name
    tokens['[HOST_EMAIL]'] = event.host.email

    if recipient.respond_to? :first_name
      tokens['[RECIPIENT_FIRST_NAME]'] = recipient.first_name
      tokens['[RECIPIENT_LAST_NAME]'] = recipient.last_name
      tokens['[RECIPIENT_NAME]'] = recipient.name
    end

    permalink = event.calendar.permalink
    tokens['[SIGNUP_LINK]'] = signup_url(:host => host, :permalink => permalink)
    tokens['[EVENT_LINK]'] = url_for(:host => host, :permalink => permalink, :controller => 'events', :action => 'show', :id => event)
    tokens['[MANAGE_LINK]'] = login_url(:host => host)
    tokens['[REPORT_LINK]'] = url_for(:host => host, :permalink => permalink, :controller => 'reports', :action => 'show', :event_id => event)
    tokens['[NEW_REPORT_LINK]'] = url_for(:host => host, :permalink => permalink, :controller => 'reports', :action => 'new', :id => event)

    event.host.custom_attributes.each do |attr|
      tokens["[HOST_CUSTOM_#{attr.name.capitalize}]"] = attr.value
    end

    tokens.each do |token, value|
      value = '' if value.nil?
      trigger.email_plain.gsub!(token, value) if trigger.email_plain
      trigger.email_html.gsub!(token, value) if trigger.email_html
      trigger.subject.gsub!(token, value) if trigger.subject
    end
  end
end
