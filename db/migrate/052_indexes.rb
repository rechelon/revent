class Indexes < ActiveRecord::Migration
  def self.up
    add_index :politicians, :state, :name => :index_politicians_on_state
    add_index :rsvps, [:attending_id, :attending_type], :name => :index_rsvps_on_attending_id_and_attending_type
    add_index :politician_invites, :politician_id, :name => :index_politician_invites_on_politician_id
    add_index :calendars, :site_id, :name => :index_calendars_on_site_id
    add_index :politicians, :district_type, :name => :index_politicians_on_district_type
    add_index :politicians, :district, :name => :index_politicians_on_district
    add_index :events, :calendar_id, :name => :index_events_on_calendar_id #duh
  end

  def self.down
    remove_index :politicians, :name => :index_politicians_on_state
    remove_index :rsvps, :name => :index_rsvps_on_attending_id_and_attending_type
    remove_index :politician_invites, :name => :index_politician_invites_on_politician_id
    remove_index :calendars, :name => :index_calendars_on_site_id
    remove_index :politicians, :name => :index_politicians_on_district_type
    remove_index :politicians, :name => :index_politicians_on_district
    remove_index :events, :name => :index_events_on_calendar_id
  end
end
