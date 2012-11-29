class AddHostEmailAndHostPhoneToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :host_email, :string
    add_column :events, :host_phone, :string
  end

  def self.down
    remove_column :events, :host_email
    remove_column :events, :host_phone
  end
end
