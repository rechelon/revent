class Candidates < ActiveRecord::Migration
  def self.up
    add_column :politicians, :type, :string
    add_column :politicians, :office, :string
  end

  def self.down
    remove_column :politicians, :type
    remove_column :politicians, :office
  end
end
