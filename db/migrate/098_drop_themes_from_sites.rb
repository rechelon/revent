class DropThemesFromSites < ActiveRecord::Migration
  def self.up
    execute <<-SQL
    UPDATE `hosts`,`sites` SET hosts.theme = sites.theme
    WHERE hosts.site_id = sites.id
    SQL
    remove_column :sites, :theme
  end

  def self.down
    add_column :sites, :theme, :string
    execute <<-SQL
    UPDATE `sites`,`hosts` SET sites.theme = hosts.theme
    WHERE hosts.site_id = sites.id
    SQL
  end
end
