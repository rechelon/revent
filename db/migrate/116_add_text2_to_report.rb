class AddText2ToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :text2, :text
  end

  def self.down
    remove_column :reports, :text2
  end
end
