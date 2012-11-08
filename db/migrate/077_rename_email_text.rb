class RenameEmailText < ActiveRecord::Migration
  def self.up
    rename_column :triggers, :email_text, :email_plain
  end

  def self.down
    rename_column :triggers, :email_plain, :email_text
  end
end
