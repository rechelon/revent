class AddAdminPermissions < ActiveRecord::Migration
  def self.up
    User.find_all_by_admin(true).each do |u|
      u.permissions << UserPermission.new(:name => 'site_admin', :value => 'true')
    end
  end

  def self.down
    UserPermission.find_all_by_name(:name => 'site_admin').each do |up|
      up.destroy
    end
  end
end
