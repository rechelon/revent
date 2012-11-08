class SyncFlickr < ActiveRecord::Migration
    def self.up
      add_column :attachments, :flickr_id, :string
    end

    def self.down
      remove_column :attachments, :flickr_id
    end
end
