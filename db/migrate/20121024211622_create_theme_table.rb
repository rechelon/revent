class CreateThemeTable < ActiveRecord::Migration
  def self.up
    create_table :themes do |t|
      t.integer :site_id
      t.string :name
    end
  end

  def self.down
    drop_table :themes
  end
end
