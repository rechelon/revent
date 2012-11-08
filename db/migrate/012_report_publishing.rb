class ReportPublishing < ActiveRecord::Migration
  def self.up
    transaction do
      add_column :reports, "status", :string
      Report.reset_column_information
      Report.find(:all).each do |r|
        r.update_attribute(:status, Report::PUBLISHED)
      end
    end
  end

  def self.down
    remove_column :reports, "status"
  end
end
