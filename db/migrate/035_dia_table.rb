class DiaTable < ActiveRecord::Migration
  def self.up
    # Event has_one :democracy_in_action_object, :as => :synced
    # User has_one :democracy_in_action_object, :as => :synced
    # DemocracyInActionObject belongs_to :synced, :polymorphic => true
    create_table :democracy_in_action_objects do |t|
      t.column :synced_type, :string
      t.column :synced_id, :integer
      t.column :table, :string
      t.column :key, :integer
      #t.column :relationship_type, :string, :default => "mirror" | "sync"
      t.column :serialized_data, :text
    end
    Event.find(:all).each do |event|
      next unless event.service_foreign_key
      event.create_democracy_in_action_object(:key => event.service_foreign_key, :table => 'event')
    end
    remove_column :events, :service_foreign_key


=begin
    create_table :democracy_in_action_meta, :id => false do |t|
      t.column :meta_type, :string
      t.column :meta_id, :integer
      t.column :key, :string
      t.column :value, :text
    end
    Event.find(:all).each do |event|
      next unlesss event.person_legislator_ids
      event.democracy_in_action_meta.person_legislator_ids = event.person_legislator_ids
    end
    remove_column :events, :person_legislator_ids #"274,11858,16662", for example

    Event.find(:all).each do |event|
      next unlesss event.campaign_key
      event.democracy_in_action_meta.campaign_key = event.campaign_key
    end
    remove_column :events, :campaign_key #"11047", for example
=end
  end

  def self.down
    add_column :events, :service_foreign_key, :string
    add_index "events", ["service_foreign_key"], :name => "index_events_on_service_foreign_key"
    Event.reset_column_information
    DemocracyInActionObject.find(:all, :conditions => "synced_type = 'Event'").each do |obj|
      obj.synced.service_foreign_key = obj.key
      obj.synced.save
    end
    drop_table :democracy_in_action_objects
  end
end
