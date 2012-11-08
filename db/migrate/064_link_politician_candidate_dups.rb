class LinkPoliticianCandidateDups < ActiveRecord::Migration
  def self.up
    add_column :politicians, :parent_id, :integer
  end

  def self.down
    remove_column :politicians, :parent_id
  end
end
