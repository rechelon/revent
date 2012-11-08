class ReporterNameAndEmail < ActiveRecord::Migration
  def self.up
    add_column :reports, "reporter_name", :string
    add_column :reports, "reporter_email", :string
  end

  def self.down
    remove_column :reports, "reporter_name"
    remove_column :reports, "reporter_email"
  end
end
