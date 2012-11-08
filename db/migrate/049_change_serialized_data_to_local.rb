class ChangeSerializedDataToLocal < ActiveRecord::Migration
  def self.up
    rename_column :democracy_in_action_objects, :serialized_data, :local
  end

  def self.down
    rename_column :democracy_in_action_objects, :local, :serialized_data
  end
end
