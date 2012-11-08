class PoliticianInviteCreatedAt < ActiveRecord::Migration
  def self.up
    add_column :politician_invites, :created_at, :datetime
  end

  def self.down
    remove_column :politician_invites, :created_at
  end
end
