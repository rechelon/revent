class BlogsIHateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :title, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :event_id, :integer
    end
  end

  def self.down
    drop_table :blogs
  end
end
