class ChangeMarkupToText < ActiveRecord::Migration
  def self.up
    change_column :theme_elements, :markdown, :text
  end

  def self.down
    change_column :theme_elements, :markdown, :string
  end
end
