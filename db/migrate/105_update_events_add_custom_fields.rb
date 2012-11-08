class UpdateEventsAddCustomFields < ActiveRecord::Migration
  def self.up
    add_column :events, :custom_1, :string
    add_column :events, :custom_2, :string
    add_column :events, :custom_3, :string
  end

  def self.down
    remove_column :events, :custom_3
    remove_column :events, :custom_2
    remove_column :events, :custom_1
  end
end
