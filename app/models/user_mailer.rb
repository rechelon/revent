class UserMailer < ActionMailer::Base
  def current_theme
  end

  def force_liquid_template
  end

  def invite(from, event, message, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    @event = event
    @message = message[:body]
    @url = url_for(:host => host, :permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event)
    separator = case message[:recipients]
      when /;/: ';'
      when /,/: ','
    end
    mail(:to => from,
         :from => from,
         :subject => message[:subject],
         :bcc => message[:recipients].split(separator).each{|email| email.strip!})
  end

  def message(from, event, message, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    @event = event
    @message = message[:body]
    @url => url_for(:host => host, :permalink => event.calendar.permalink, :controller => 'events', :action => 'show', :id => event)
    mail(:to => from,
         :from => from,
         :bcc => (event.attendees || event.to_democracy_in_action_event.attendees.collect {|a| User.new :email => a.Email}).collect {|a| a.email}.compact.join(','),
         :subject => message[:subject])
  end

  def invalid(event, errors)
    @text = event.to_yaml + errors
    mail(:to => SUPERUSERS,
         :from => 'events@radicaldesigns.org',
         :subject => 'invalid event')
  end

  def activation(user)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    @url => url_for(:host => host, :controller => 'account', :action => 'activate', :id => user.activation_code)
    mail(:to => user.email,
         :from => admin_email(user) || 'events@radicaldesigns.org',
         :subject => "Account Avtivation on #{host}")
  end

  def forgot_password(user, host=nil)
    host ||= Site.current.host.hostname if Site.current && Site.current.host
    opts = setup_email(user)
    opts[:subject] += "Request to change your password"
    @url  = "http://#{host}/account/reset_password/#{user.password_reset_code}" 
    @user = user
    mail(opts)
  end

  def reset_password(user)
    host = Site.current && Site.current.host ? Site.current.host.hostname : ''
    opts = setup_email(user)
    opts[:subject]    += 'Your password has been reset'
    @url = login_url(:host => host)
    @user = user
    mail(opts)
  end

  def message_to_host(message, host)
    @body = message[:body]
    mail(:to => host.email,
         :from => message[:from],
         :subject => message[:subject])
         
  end

  def message_to_email(message, email)
    @body = message[:body]
    mail(:to => email,
         :from => message[:from],
         :subject => message[:subject])
  end
 
  protected
  def setup_email(user)
    host = Site.current && Site.current.host ? Site.current.host.hostname : ''
    {
      :to          => "#{user.email}" 
      :from        => admin_email(user) || 'events@radicaldesigns.org'
      :subject     => "#{host} - "
    }
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

end
