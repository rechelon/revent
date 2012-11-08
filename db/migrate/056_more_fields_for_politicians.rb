class MoreFieldsForPoliticians < ActiveRecord::Migration
  def self.up
    add_column :politicians, :fax, :string
    add_column :politicians, :web_form, :string
  end

  def self.down
    remove_column :politicians, :web_form
    remove_column :politicians, :fax
  end
end
