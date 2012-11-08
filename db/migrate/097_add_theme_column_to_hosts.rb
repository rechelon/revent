class AddThemeColumnToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :theme, :string
  end

  def self.down
    remove_column :hosts, :theme
  end
end
