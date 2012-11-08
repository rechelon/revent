class EmbedsTable < ActiveRecord::Migration
  def self.up
    create_table :embeds do |t|
      t.column :html, :text
      t.column :caption, :string
      t.column :user_id, :integer
      t.column :youtube_video_id, :string
      t.column :preview_url, :string
      t.column :report_id, :integer
    end
  end

  def self.down
    drop_table :embeds
  end
end
