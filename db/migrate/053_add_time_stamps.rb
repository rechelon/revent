class AddTimeStamps < ActiveRecord::Migration
  def self.up
    # add created_at fields to all tables
    add_column :attachments,         :created_at, :datetime
    add_column :calendars,           :created_at, :datetime
    add_column :democracy_in_action_objects, :created_at, :datetime
    add_column :events,              :created_at, :datetime
    add_column :politicians,         :created_at, :datetime
    add_column :press_links,         :created_at, :datetime
    add_column :reports,             :created_at, :datetime
    add_column :rsvps,               :created_at, :datetime
    add_column :sites,               :created_at, :datetime
    add_column :tags,                :created_at, :datetime
    add_column :taggings,            :created_at, :datetime
    add_column :zip_codes,           :created_at, :datetime
    
    # add updated_at fields to all tables
    add_column :attachments,         :updated_at, :datetime
    add_column :calendars,           :updated_at, :datetime
    add_column :democracy_in_action_objects, :updated_at, :datetime
    add_column :events,              :updated_at, :datetime
    add_column :politicians,         :updated_at, :datetime
    add_column :politician_invites,  :updated_at, :datetime
    add_column :press_links,         :updated_at, :datetime
    add_column :reports,             :updated_at, :datetime
    add_column :rsvps,               :updated_at, :datetime
    add_column :sites,               :updated_at, :datetime
    add_column :tags,                :updated_at, :datetime
    add_column :taggings,            :updated_at, :datetime
    add_column :zip_codes,           :updated_at, :datetime
  end
  
  def self.down
    # remove created_at fields to all tables
    remove_column :attachments,         :created_at
    remove_column :calendars,           :created_at
    remove_column :democracy_in_action_objects, :created_at
    remove_column :events,              :created_at
    remove_column :politicians,         :created_at
    remove_column :press_links,         :created_at
    remove_column :reports,             :created_at
    remove_column :rsvps,               :created_at
    remove_column :sites,               :created_at
    remove_column :tags,                :created_at
    remove_column :taggings,            :created_at
    remove_column :zip_codes,           :created_at
    
    # remove updated_at fields to all tables                    
    remove_column :attachments,         :updated_at
    remove_column :calendars,           :updated_at
    remove_column :democracy_in_action_objects, :updated_at
    remove_column :events,              :updated_at
    remove_column :politicians,         :updated_at
    remove_column :politician_invites,  :updated_at
    remove_column :press_links,         :updated_at
    remove_column :reports,             :updated_at
    remove_column :rsvps,               :updated_at
    remove_column :sites,               :updated_at
    remove_column :tags,                :updated_at
    remove_column :taggings,            :updated_at
    remove_column :zip_codes,           :updated_at   
  end
end
