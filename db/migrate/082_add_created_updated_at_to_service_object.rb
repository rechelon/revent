class AddCreatedUpdatedAtToServiceObject < ActiveRecord::Migration
  def self.up
    add_column :service_objects, :created_at, :datetime
    add_column :service_objects, :updated_at, :datetime
  end

  def self.down
    remove_column :service_objects, :created_at
    remove_column :service_objects, :updated_at
  end
end
