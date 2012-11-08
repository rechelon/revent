class AddHostScriptEditing < ActiveRecord::Migration
  def self.up
    add_column :calendars, :letter_script, :text
    add_column :calendars, :call_script, :text
    add_column :events, :letter_script, :text
    add_column :events, :call_script, :text
  end
  
  def self.down
    remove_column :calendars, :letter_script
    remove_column :calendars, :call_script
    remove_column :events, :letter_script
    remove_column :events, :call_script
  end
end
