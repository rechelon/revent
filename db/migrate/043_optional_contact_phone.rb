class OptionalContactPhone < ActiveRecord::Migration
  def self.up
    add_column :users, :show_phone_on_host_profile, :boolean
  end

  def self.down
    remove_column :users, :show_phone_on_host_profile
  end
end
