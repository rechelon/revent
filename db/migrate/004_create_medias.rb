class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      t.column "width", :integer  
      t.column "height", :integer

      t.column :caption, :string
      t.column :url, :string
      t.column :position, :integer
      t.column :author, :string
      t.column :type, :string
      t.column :user_id, :integer
      t.column :event_id, :integer
    end

    # only for db-based files
    # create_table :db_files, :force => true do |t|
    #      t.column :data, :binary
    # end
  end

  def self.down
    drop_table :medias
    
    # only for db-based files
    # drop_table :db_files
  end
end
