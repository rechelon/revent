class SignupRedirects < ActiveRecord::Migration
  def self.up
    add_column :calendars, :signup_redirect, :string
  end

  def self.down
    remove_column :calendars, :signup_redirect
  end
end
