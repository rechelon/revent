class UpdateAttachmentFields < ActiveRecord::Migration
  def self.up
    remove_column :attachments, :author, :type, :position, :url, :user_id, :flickr_id
    add_column :attachments, :old, :boolean, :default => false
    Attachment.update_all ["old = ?", true]
    Attachment.find_all_by_thumbnail("display").each do |a|
      a.thumbnail = "pageview"
      a.save
    end
  end

  def self.down
    remove_column :attachments, :old
    add_column :attachments, :author, :string
    add_column :attachments, :type, :string
    add_column :attachments, :position, :integer
    add_column :attachments, :url, :string
    add_column :attachments, :user_id, :integer
    add_column :attachments, :flickr_id, :string
    Attachment.find_all_by_thumbnail("pageview").each do |a|
      a.thumbnail = "display"
      a.save
    end

  end
end
