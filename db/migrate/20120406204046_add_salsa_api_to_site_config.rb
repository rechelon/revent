class AddSalsaApiToSiteConfig < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :salsa_user, :string
    add_column :site_configs, :salsa_pass, :string
    add_column :site_configs, :salsa_node, :string
  end

  def self.down
    remove_column :site_configs, :salsa_node
    remove_column :site_configs, :salsa_pass
    remove_column :site_configs, :salsa_user
  end
end
