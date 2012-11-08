class AssociatedDemocracyInActionObjects < ActiveRecord::Migration
  def self.up
    add_column :democracy_in_action_objects, :associated_type, :string
    add_column :democracy_in_action_objects, :associated_id, :integer
  end

  def self.down
    remove_column :democracy_in_action_objects, :associated_type
    remove_column :democracy_in_action_objects, :associated_id
  end
end
