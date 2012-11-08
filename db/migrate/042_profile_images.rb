class ProfileImages < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_image_id, :integer
  end

  def self.down
    remove_column :users, :profile_image_id
  end
end
