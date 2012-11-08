class AddAttendeeInviteScript < ActiveRecord::Migration
  def self.up
    add_column :calendars, :attendee_invite_subject, :string
    add_column :calendars, :attendee_invite_message, :text
  end
  
  def self.down
    remove_column :calendars, :attendee_invite_subject
    remove_column :calendars, :attendee_invite_message
  end
end
