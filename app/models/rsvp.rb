class Rsvp < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  belongs_to :attending, :polymorphic => true
  
  after_create :trigger_email
  def trigger_email
    calendar = self.event.calendar
    unless calendar.rsvp_dia_trigger_key
      trigger = calendar.triggers.find_by_name("RSVP Thank You") || Site.current.triggers.find_by_name("RSVP Thank You")
      TriggerMailer.trigger(trigger, self.user, self.event).deliver if trigger
    end
  end

end
