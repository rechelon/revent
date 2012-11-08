class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :site_id, :name => 'index_users_on_site_id' rescue Mysql::Error
    add_index :custom_attributes, :user_id, :name => 'index_custom_attributes_on_user_id' rescue Mysql::Error
    add_index :events, :host_id, :name => 'index_events_on_host_id' rescue Mysql::Error
  end

  def self.down
    remove_index :events, :name => 'index_events_on_host_id'
    remove_index :custom_attributes, :name => 'index_custom_attributes_on_user_id'
    remove_index :users, :name => 'index_users_on_site_id'
  end
end
