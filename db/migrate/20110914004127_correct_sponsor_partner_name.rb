class CorrectSponsorPartnerName < ActiveRecord::Migration
  def self.up
    rename_column :sponsors, :parter_code, :partner_code
  end

  def self.down
    rename_column :sponsors, :partner_code, :parter_code
  end
end
