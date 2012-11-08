class StoreSalesforceId < ActiveRecord::Migration
  def self.up
    create_table :service_objects do |t|
      t.string  :mirrored_type  # local type 
      t.integer :mirrored_id    # local id 
      t.string  :remote_service
      t.string  :remote_type
      t.string  :remote_id
    end
  end

  def self.down
    drop_table :service_objects
  end
end
