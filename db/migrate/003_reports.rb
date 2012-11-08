class Reports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.column :event_id, :integer
      t.column :user_id, :integer
      t.column :text, :text
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :reports
  end
end
