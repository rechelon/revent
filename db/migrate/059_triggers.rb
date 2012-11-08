class Triggers < ActiveRecord::Migration
  def self.up
    create_table "triggers", :force => true do |t|
      t.column :name, 			:string
      t.column :from, 			:string
      t.column :from_name, 		:string
      t.column :reply_to, 		:string
      t.column :subject, 		:string
      t.column :bcc, 			:string
      t.column :email_text, 	:text
      t.column :email_html, 	:text
      t.column :calendar_id, 	:integer
      t.column :site_id, 		:integer
      t.column :created_at, 	:datetime
      t.column :updated_at, 	:datetime      
    end
   end

  def self.down
    drop_table "triggers"
  end
end