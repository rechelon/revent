class LeaderRsvps < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :attending_type, :string
    add_column :rsvps, :attending_id, :integer
  end

  def self.down
    remove_column :rsvps, :attending_type
    remove_column :rsvps, :attending_id
  end
end
