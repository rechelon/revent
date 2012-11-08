class Role < ActiveRecord::Base
end
class User
  has_and_belongs_to_many :roles
end

class RolesSuck < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean
    admins = User.find(:all, :include => :roles, :conditions => "roles.title = 'admin'")
    User.update_all ["admin = ?", true], ["id IN (?)", admins.map {|admin| admin.id}]
    drop_table :roles 
    drop_table :roles_users
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
