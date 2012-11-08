class AddSubtitleToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :subtitle, :text
  end

  def self.down
    remove_column :events, :subtitle
  end
end
