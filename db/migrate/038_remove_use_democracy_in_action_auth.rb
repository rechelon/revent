class RemoveUseDemocracyInActionAuth < ActiveRecord::Migration
  def self.up
    remove_column :sites, :use_democracy_in_action_auth
  end

  def self.down
    add_column :sites, :use_democracy_in_action_auth, :boolean  
  end
end
