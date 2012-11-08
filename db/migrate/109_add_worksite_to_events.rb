class AddWorksiteToEvents < ActiveRecord::Migration
  def self.up
    add_column 'events', 'worksite_event', :boolean
    add_index 'events', 'worksite_event'
  end

  def self.down
    remove_index 'events', :column => 'worksite_event'
    remove_column 'events', 'worksite_event'
  end
end
