class CreateSponsors < ActiveRecord::Migration
  def self.up
    create_table :sponsors do |t|
      t.string :name
      t.text :description
      t.string :parter_code
      t.integer :site_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sponsors
  end
end
