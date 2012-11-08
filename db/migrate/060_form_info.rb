class FormInfo < ActiveRecord::Migration
  def self.up
    add_column :calendars, :hostform_id, :integer
    add_column :calendars, :rsvp_dia_group_key, :integer
    add_column :calendars, :rsvp_dia_trigger_key, :integer
    add_column :calendars, :report_dia_group_key, :integer
    add_column :calendars, :report_dia_trigger_key, :integer    

    create_table :hostforms do |t|
      t.column :title, :string
      t.column :intro_text, :text
      t.column :event_info_text, :text
      t.column :thank_you_text, :text
      t.column :pre_submit_text, :text
      t.column :trigger_id, :integer
      t.column :dia_trigger_key, :integer
      t.column :dia_group_key, :integer
      t.column :dia_user_tracking_code, :string
	  t.column :dia_event_tracking_code, :string      
      t.column :tag, :string
      t.column :redirect, :string
      t.column :calendar_id, :integer
      t.column :site_id, :integer
    end
	
  end

  def self.down
  	drop_table :hostforms
    remove_column :calendars, :hostform_id
    remove_column :calendars, :rsvp_dia_group_key
    remove_column :calendars, :rsvp_dia_trigger_key
    remove_column :calendars, :report_dia_group_key
    remove_column :calendars, :report_dia_trigger_key
  end
end
