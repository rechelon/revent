class RsvpsNeedPrimaryKeys < ActiveRecord::Migration
  class TempRsvp < ActiveRecord::Base
  end
  def self.up
    create_table :temp_rsvps do |t|
      t.column :event_id, :integer
      t.column :user_id, :integer
      t.column :comment, :text
      t.column :guests, :integer
    end
    Rsvp.find(:all).each do |r|
      TempRsvp.create :event_id => r.event_id, :user_id => r.user_id, :comment => r.comment, :guests => r.guests
    end
    drop_table :rsvps
    create_table :rsvps do |t|
      t.column :event_id, :integer
      t.column :user_id, :integer
      t.column :comment, :text
      t.column :guests, :integer
    end
    TempRsvp.find(:all).each do |r|
      Rsvp.create :event_id => r.event_id, :user_id => r.user_id, :comment => r.comment, :guests => r.guests
    end
    drop_table :temp_rsvps
  end

  def self.down
    remove_column :rsvps, :id
  end
end
