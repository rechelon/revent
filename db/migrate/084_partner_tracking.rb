class PartnerTracking < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_id, :string
  end

  def self.down
    remove_column :users, :partner_id
  end
end
