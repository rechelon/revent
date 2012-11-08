class DropHostFromSites < ActiveRecord::Migration
  def self.up
    remove_column :sites, :host
  end

  def self.down
   add_column :sites, :host, :string
    Site.find(:all).each do |site|
      h = site.hosts.first
      execute("UPDATE `sites` SET host = '#{h.hostname}' WHERE sites.id = #{h.site_id}");
    end
  end
end
