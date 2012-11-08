class CategorySite < ActiveRecord::Migration
  def self.up
    add_column :categories, :calendar_id, :integer
    add_column :categories, :site_id, :integer
  end

  def self.down
    remove_column :categories, :calendar_id
    remove_column :categories, :site_id
  end
end
