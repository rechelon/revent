class AddFbIdColumnToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :fb_id, :string
  end

  def self.down
    remove_column :events, :fb_id
  end
end
