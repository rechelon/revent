class GreenforallUserMetadata < ActiveRecord::Migration
  def self.up
    create_table :custom_attributes do |t|
      t.integer 'user_id'
      t.string  'name', 'value'
    end
  end

  def self.down
    drop_table :custom_attributes
  end
end
