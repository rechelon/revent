class Events < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :name, :string
      t.column :short_description, :text
      t.column :description, :text
      t.column :event_group_id, :integer
      t.column :location, :text
      t.column :city, :string
      t.column :state, :string
      t.column :postal_code, :string
      t.column :host_id, :integer
      t.column :start, :datetime
      t.column :end, :datetime
    end

    create_table :event_groups do |t|
      t.column :name, :string
      t.column :short_description, :text
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :events
    drop_table :event_groups
  end
end
