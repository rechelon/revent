class RenameVarnishServerColumn < ActiveRecord::Migration
  def self.up
    rename_column :site_configs, :varnish_server_url, :varnish_servers
  end

  def self.down
    rename_column :site_configs, :varnish_servers, :varnish_server_url
  end
end
