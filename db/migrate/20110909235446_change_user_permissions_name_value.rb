class ChangeUserPermissionsNameValue < ActiveRecord::Migration
  def self.up
    rename_column :user_permissions, :permission_name, :name
    rename_column :user_permissions, :permission_value, :value
  end

  def self.down
    rename_column :user_permissions, :name, :permission_name
    rename_column :user_permissions, :value, :permission_value
  end
end
