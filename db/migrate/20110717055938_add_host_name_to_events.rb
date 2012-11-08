class AddHostNameToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    belongs_to :host, :class_name => 'User', :foreign_key => 'host_id'
  end

  def self.up
    add_column :events, :host_first_name, :string
    add_column :events, :host_last_name, :string
    add_index :events, :host_last_name
    Event.reset_column_information
    puts Event.count
    i = 0
    Event.all(:include => :host).each do |event|
      next if event.host.nil?
      event.host_first_name = event.host.first_name
      event.host_last_name = event.host.last_name
      event.save!
      i = i+1
    end
    puts i
  end

  def self.down
    remove_index :events, :column => :host_last_name
    remove_column :events, :host_last_name
    remove_column :events, :host_first_name
  end
end
