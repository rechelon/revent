class IndexAttachments < ActiveRecord::Migration
  def self.up
    add_index :attachments, :parent_id, :name => 'index_attachments_on_parent_id'
  end

  def self.down
    remove_index :attachments, :name => 'index_attachments_on_parent_id'
  end
end
