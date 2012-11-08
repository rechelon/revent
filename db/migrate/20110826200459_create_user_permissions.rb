class CreateUserPermissions < ActiveRecord::Migration
  def self.up
    create_table :user_permissions do |t|
      t.integer :user_id
      t.string :permission_name
      t.string :permission_value

      t.timestamps
    end
  end

  def self.down
    drop_table :user_permissions
  end
end
