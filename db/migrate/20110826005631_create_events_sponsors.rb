class CreateEventsSponsors < ActiveRecord::Migration
  def self.up
    create_table :events_sponsors, :id => false do |t|
      t.references :event, :sponsor
    end
  end

  def self.down
  end
end

