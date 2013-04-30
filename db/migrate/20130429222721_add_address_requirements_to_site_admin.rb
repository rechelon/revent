class AddAddressRequirementsToSiteAdmin < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :event_address_required, :boolean, :default => true
    add_column :site_configs, :user_full_address_required, :boolean, :default => false
  end

  def self.down
    remove_column :site_configs, :event_address_required
    remove_column :site_configs, :user_full_address_required
  end
end
