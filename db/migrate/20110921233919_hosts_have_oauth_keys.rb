class HostsHaveOauthKeys < ActiveRecord::Migration
  def self.up
    add_column :hosts, :fb_app_id, :string
    add_column :hosts, :fb_app_secret, :string
    add_column :hosts, :google_oath_key, :string
    add_column :hosts, :google_oath_secret, :string
    add_column :hosts, :twitter_oath_key, :string
    add_column :hosts, :twitter_oath_secret, :string
  end

  def self.down
    remove_column :hosts, :twitter_oath_secret
    remove_column :hosts, :twitter_oath_key
    remove_column :hosts, :google_oath_secret
    remove_column :hosts, :google_oath_key
    remove_column :hosts, :fb_app_secret
    remove_column :hosts, :fb_app_id
  end
end
