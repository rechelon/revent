class CreateEventCustomAttributes < ActiveRecord::Migration
  def self.up
    create_table :event_custom_attributes do |t|
      t.integer :event_id
      t.string :name
      t.string :value

      t.timestamps
    end
    add_index :event_custom_attributes, :event_id
  end

  def self.down
    drop_table :event_custom_attributes
  end
end
