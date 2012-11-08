class PressLinks < ActiveRecord::Migration
  def self.up
    create_table :press_links do |t|
      t.column :url, :string
      t.column :text, :string
      t.column :report_id, :integer
    end
  end

  def self.down
    drop_table :press_links
  end
end
