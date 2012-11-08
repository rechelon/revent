class PartnerRedirectUrl < ActiveRecord::Migration
  def self.up
    add_column :sites, :partner_redirect_url, :string
  end

  def self.down
    remove_column :sites, :partner_redirect_url
  end
end
