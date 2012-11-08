class AddStateandStartIndexesToEvents < ActiveRecord::Migration
  def self.up
    add_index :events, :state
    add_index :events, :start
  end

  def self.down
    remove_index :events, :column => :start
    remove_index :events, :column => :state
  end
end
