class PrimaryImages < ActiveRecord::Migration
  def self.up
    add_column :attachments, :primary, :boolean, :default => false
  end

  def self.down
    remove_column :attachments, :primary
  end
end
