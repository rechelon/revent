class NewEventStuff < ActiveRecord::Migration
  def self.up
    add_column :events, :private, :boolean
    add_column :events, :max_attendees, :integer
    add_column :events, :category_id, :integer
    create_table :categories do |t|
      t.column :name, :string
      t.column :description, :string
    end
  end

  def self.down
    drop_table :categories
    remove_column :events, :category_id
    remove_column :events, :max_attendees
    remove_column :events, :private
  end
end
