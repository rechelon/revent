class RenameOauthTypos < ActiveRecord::Migration
  def self.up
    rename_column :hosts, :google_oath_key, :google_oauth_key 
    rename_column :hosts, :google_oath_secret, :google_oauth_secret
    rename_column :hosts, :twitter_oath_key, :twitter_oauth_key
    rename_column :hosts, :twitter_oath_secret, :twitter_oauth_secret
  end

  def self.down
    rename_column :hosts, :twitter_oauth_secret, :twitter_oath_secret
    rename_column :hosts, :twitter_oauth_key, :twitter_oath_key
    rename_column :hosts, :google_oauth_secret, :google_oath_secret
    rename_column :hosts, :google_oauth_key , :google_oath_key
  end
end
