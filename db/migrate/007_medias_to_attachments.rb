class MediasToAttachments < ActiveRecord::Migration
  def self.up
    rename_table "medias", "attachments"
    add_column "attachments", "report_id", :integer
  end

  def self.down
    rename_table "attachments", "medias"
    remove_column "medias", "report_id"
  end
end
