class AddMollomKeysToSite < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :mollom_api_public_key, :string
    add_column :site_configs, :mollom_api_private_key, :string
  end

  def self.down
    remove_column :site_configs, :mollom_api_public_key
    remove_column :site_configs, :mollom_api_private_key
  end
end
