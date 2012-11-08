class Rsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps, :id => false do |t|
      t.column :event_id, :integer
      t.column :user_id, :integer
      t.column :comment, :text
      t.column :guests, :integer
    end
  end

  def self.down
    drop_table :rsvps
  end
end
