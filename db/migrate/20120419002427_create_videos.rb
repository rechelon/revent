class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :title
      t.string :vid, :length => 512
      t.string :service
      t.integer :user_id, :default => nil
      t.integer :report_id, :default => nil
    end
  end

  def self.down
   drop_table :videos
  end
end
