class UserMailer < ActionMailer::Base
  def current_theme
  end

  def force_liquid_template
  end

  def invite(from, event, message, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    @subject    = message[:subject]
    @body       = {:event => event, :message => message[:body], :url => url_for(:host => host, :permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event)}
    @recipients = from
    separator = case message[:recipients]
      when /;/: ';'
      when /,/: ','
    end
    @bcc        = message[:recipients].split(separator).each{|email| email.strip!}
    @from       = from
    @headers    = {}
  end

  def message(from, event, message, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    @subject    = message[:subject]
    @body       = {:event => event, :message => message[:body], :url => url_for(:host => host, :permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event)}
    @recipients = from
    @bcc        = (event.attendees || event.to_democracy_in_action_event.attendees.collect {|a| User.new :email => a.Email}).collect {|a| a.email}.compact.join(',')
    @from       = from
    @headers    = {}
  end

  def invalid(event, errors)
    @subject    = 'invalid event'
    @body       =  {:text => event.to_yaml + errors}
    @recipients = SUPERUSERS
    @from       = 'events@radicaldesigns.org'
    @headers    = {}
  end

  def activation(user)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    subject       "Account Activation on #{host}"
    body          :url => url_for(:host => host, :controller => 'account', :action => 'activate', :id => user.activation_code)
    recipients    user.email
    from          admin_email(user) || 'events@radicaldesigns.org'
    headers       {}
  end

  def forgot_password(user, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "http://#{host}/account/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    host = Site.current && Site.current.host ? Site.current.host.hostname : ''
    setup_email(user)
    @subject    += 'Your password has been reset'
    @body[:url] = login_url(:host => host)
  end
  
  protected
  def setup_email(user)
    host = Site.current && Site.current.host ? Site.current.host.hostname : ''
    @recipients  = "#{user.email}" 
    @from        = admin_email(user) || 'events@radicaldesigns.org'
    @subject     = "#{host} - "
    @body[:user] = user
  end
  
  def admin_email(user)
    calendar = 
      if user.events.any?
        user.events.last.calendar
      elsif user.rsvps.any?
        user.rsvps.last.event.calendar
      elsif user.reports.any?
        user.reports.last.event.calendar
      else
        Site.current.calendars.detect {|c| c.current?} || Site.current.calendars.first
      end
    calendar ? calendar.admin_email : nil
  end  

  def message_to_host(message, host)
    @recipients = host.email
    @from       = message[:from]
    @subject    = message[:subject]
    @body       = message[:body]
  end

  def message_to_email(message, email)
    @recipients = email
    @from       = message[:from]
    @subject    = message[:subject]
    @body       = message[:body]
  end
end
