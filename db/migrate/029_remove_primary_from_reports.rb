class RemovePrimaryFromReports < ActiveRecord::Migration
  def self.up
    remove_column :reports, :primary
  end

  def self.down
    raise IrreversibleMigration
  end
end
