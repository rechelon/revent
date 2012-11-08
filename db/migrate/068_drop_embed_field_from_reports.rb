class DropEmbedFieldFromReports < ActiveRecord::Migration
  def self.up
    reports = Report.find(:all, :conditions => "embed <> ''")
    reports.each do |r|
      r.embeds.create :html => r.embed, :user_id => r.user_id
    end
    remove_column :reports, :embed
  end

  def self.down
    raise IrreversibleMigration
  end
end
