class AddIconsToSiteConfig < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :icon_upcoming, :text
    add_column :site_configs, :icon_past, :text
    add_column :site_configs, :icon_worksite, :text
  end

  def self.down
    remove_column :site_configs, :icon_worksite
    remove_column :site_configs, :icon_past
    remove_column :site_configs, :icon_upcoming
  end
end
