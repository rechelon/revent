class AddHostAliasToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :host_alias, :boolean
  end

  def self.down
    add_column :events, :host_alias, :boolean
  end
end
