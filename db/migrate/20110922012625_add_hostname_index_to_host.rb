class AddHostnameIndexToHost < ActiveRecord::Migration
  def self.up
    add_index :hosts, :hostname
  end

  def self.down
    remove_index :hosts, :column => :hostname
  end
end
