class RemoveTagsFromHostforms < ActiveRecord::Migration
  def self.up
    remove_column :hostforms, :tag
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
