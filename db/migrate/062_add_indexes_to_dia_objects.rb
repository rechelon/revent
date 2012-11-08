class AddIndexesToDiaObjects < ActiveRecord::Migration
  def self.up
    add_index :democracy_in_action_objects, [:synced_id, :synced_type], :name => "index_on_synced_id_and_synced_type"
    add_index :democracy_in_action_objects, [:associated_id, :associated_type], :name => "index_on_associated_id_and_associated_type"
  end

  def self.down
    remove_index :democracy_in_action_objects, :name => "index_on_associated_id_and_associated_type"
    remove_index :democracy_in_action_objects, :name => "index_on_synced_id_and_synced_type"
  end
end
