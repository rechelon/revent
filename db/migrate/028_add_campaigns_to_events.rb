class AddCampaignsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :person_legislator_ids, :string
    add_column :events, :district, :string
    add_column :events, :campaign_key, :integer
  end

  def self.down
    remove_column :events, :person_legislator_ids
    remove_column :events, :district
    remove_column :events, :campaign_key
  end
end
