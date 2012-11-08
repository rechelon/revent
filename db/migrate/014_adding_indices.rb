class AddingIndices < ActiveRecord::Migration
  def self.up
    add_index :reports, :event_id, :name => 'index_reports_on_event_id'
    add_index :reports, :status, :name => 'index_reports_on_status'
    add_index :reports, [:status, :position], :name => 'index_reports_on_status_and_position'
    add_index :events, [:latitude, :longitude], :name => 'index_events_on_latitude_and_longitude'
    add_index :events, :postal_code, :name => 'index_events_on_postal_code'
    add_index :events, [:state, :city], :name => 'index_events_on_state_and_city'
    add_index :attachments, :report_id, :name => 'index_attachments_on_report_id'
  end

  def self.down
    remove_index :reports, :name => 'index_reports_on_event_id'
    remove_index :reports, :name => 'index_reports_on_status'
    remove_index :reports, :name => 'index_reports_on_status_and_position'
    remove_index :events, :name => 'index_events_on_latitude_and_longitude'
    remove_index :events, :name => 'index_events_on_postal_code'
    remove_index :events, :name => 'index_events_on_state_and_city'
    remove_index :attachments, :name => 'index_attachments_on_report_id'
  end
end
