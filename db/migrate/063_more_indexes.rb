class MoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :democracy_in_action_objects, [:table, :key], :name => "index_on_table_and_key"
    add_index :politicians, :type, :name => "index_politicians_on_type"
    add_index :press_links, :report_id, :name => "index_press_links_on_report_id"
    add_index :attachments, :event_id, :name => "index_attachments_on_event_id"
    add_index :attachments, :content_type, :name => "index_attachments_on_content_type"
    add_index :blogs, :event_id, :name => "index_blogs_on_event_id"
    add_index :rsvps, :event_id, :name => "index_rsvps_on_event_id"
    add_index :rsvps, :user_id, :name => "index_rsvps_on_user_id"
    execute "CREATE INDEX #{quote_column_name('index_reports_on_embed')} ON reports (#{quote_column_name('embed')}(128))"
    remove_index :reports, :name => "index_reports_on_status" #unnecessary
    add_index :roles_users, [:role_id, :user_id], :name => "unique_index_on_role_id_and_user_id", :unique => true
    add_index :users, [:email, :site_id], :name => "unique_index_on_email_and_site_id"
    add_index :politicians, :person_legislator_id, :name => "index_on_person_legislator_id"
  end

  def self.down
    remove_index :politicians, :name => "index_on_person_legislator_id"
    remove_index :users, :name => "unique_index_on_email_and_site_id"
    remove_index :roles_users, :name => "unique_index_on_role_id_and_user_id"
    add_index :reports, :name => "index_reports_on_status" #unnecessary
    remove_index :reports, :name => "index_reports_on_embed"
    remove_index :rsvps, :name => "index_rsvps_on_user_id"
    remove_index :rsvps, :name => "index_rsvps_on_event_id"
    remove_index :blogs, :name => "index_blogs_on_event_id"
    remove_index :attachments, :name => "index_attachments_on_content_type"
    remove_index :attachments, :name => "index_attachments_on_event_id"
    remove_index :press_links, :name => "index_press_links_on_report_id"
    remove_index :politicians, :name => "index_politicians_on_type"
    remove_index :democracy_in_action_objects, :name => "index_on_table_and_key"
  end
end
