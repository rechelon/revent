class ReportsDefaultToUnpublished < ActiveRecord::Migration
  def self.up
    change_column_default :reports, :status, 'unpublished'
  end

  def self.down
    change_column_default :reports, :status, ''
  end
end
