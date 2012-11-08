class CreateSponsorsUsersAndSponsorsReports < ActiveRecord::Migration
  def self.up
    create_table :sponsors_users, :id => false do |t|
      t.references :sponsor, :user
    end
    create_table :reports_sponsors, :id => false do |t|
      t.references :report, :sponsor
    end
  end

  def self.down
  end
end

