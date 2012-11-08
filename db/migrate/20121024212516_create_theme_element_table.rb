class CreateThemeElementTable < ActiveRecord::Migration
  def self.up
    create_table :theme_elements do |t|
      t.integer :theme_id
      t.string :name 
      t.string :markdown
    end
  end

  def self.down
    drop_table :theme_elements
  end
end
