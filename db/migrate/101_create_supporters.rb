class CreateSupporters < ActiveRecord::Migration
  def self.up
    create_table :supporters do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :latitude
      t.string :longitude
      t.string :street
      t.string :precision
      t.string :dia_supporter_id
      t.string :dia_group_keys

      t.timestamps
    end
  end

  def self.down
    drop_table :supporters
  end
end
