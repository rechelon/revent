class AddIndexOnServiceForeignKey < ActiveRecord::Migration
  def self.up
    add_index :events, :service_foreign_key, :name => 'index_events_on_service_foreign_key'
  end

  def self.down
    remove_index :events, :name => 'index_events_on_service_foreign_key'
  end
end
