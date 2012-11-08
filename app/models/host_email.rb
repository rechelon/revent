# The intention with this class is to allow validations for
# the email to host form where there is no ActiveRecord model.
# We followed the advice in this post but we're not on rails 2.1
# yet so it didn't work:
#  http://mislav.caboo.se/rails/validations-in-any-class/
class HostEmail
  attr_accessor :from_name, :from_email, :subject, :body, :host

  def initialize(attrs = {})
    for key, value in attrs
      update_attribute(key, value)
    end
    @new_record = true
  end

  def save
    message = {
      :from => "\"#{from_name}\" <#{from_email}>", 
      :subject => subject, 
      :body => body }
    UserMailer.deliver_message_to_host(message, host)
    @new_record = false
    return true
  end

  alias :save! :save

  def new_record?() @new_record; end

  include ActiveRecord::Validations
  #validates_presence_of :from_email, :subject
  #validates_format_of :from_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  

  def update_attribute(key, value)
    send "#{key}=", value
  end
end
