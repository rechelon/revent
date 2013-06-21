class Rsvp < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  belongs_to :attending, :polymorphic => true
  
  after_create :trigger_email_to_user, :trigger_email_to_host
  def trigger_email_to_user
    calendar = self.event.calendar
    unless calendar.rsvp_dia_trigger_key
      trigger = calendar.triggers.find_by_name("RSVP Thank You") || Site.current.triggers.find_by_name("RSVP Thank You")
      TriggerMailer.trigger(trigger, self.user, self.event).deliver if trigger
    end
  end

  def trigger_email_to_host
    calendar = self.event.calendar
    trigger = calendar.triggers.find_by_name("RSVP Notify Host") || Site.current.triggers.find_by_name("RSVP Notify Host")
    TriggerMailer.trigger(trigger, self.event.host, self.event).deliver if trigger
  end
  
end
