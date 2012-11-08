class SqlTuning < ActiveRecord::Migration
  def self.up
#    add_index :sites, :name => "index_sites_on_host", :unique => true
    remove_index :sites, :name => "index_sites_on_host"
    remove_index :events, :name => "index_events_on_state_and_city"
    remove_index :zip_codes, :name => "index_zip_codes_on_zip"
    execute "CREATE UNIQUE INDEX index_sites_on_host ON sites(host(64))"
    execute "CREATE INDEX index_events_on_state_and_city ON events(state(2),city(64))"
    execute "CREATE INDEX index_zip_codes_on_zip ON zip_codes(zip(15))"
    add_index :categories, :calendar_id, :name => "index_categories_on_calendar_id"
    add_index :hostforms, :calendar_id, :name => "index_hostforms_on_calendar_id"
  end

  def self.down
    remove_index :sites, :name => "index_sites_on_host"
    remove_index :events, :name => "index_events_on_state_and_city"
    remove_index :zip_codes, :name => "index_zip_codes_on_zip"
    add_index :sites, "host", :name => "index_sites_on_host"
    add_index :events, ["state", "city"], :name => "index_events_on_state_and_city"
    add_index :zip_codes, "zip", :name => "index_zip_codes_on_zip"
    remove_index :categories, :name => "index_categories_on_calendar_id"
    remove_index :hostforms, :name => "index_hostforms_on_calendar_id"
  end
end
