class RemoveVarnishServerColumn < ActiveRecord::Migration
  def self.up
    remove_column :site_configs, :varnish_servers
  end

  def self.down
    add_column :site_configs, :varnish_servers, :string
  end
end
