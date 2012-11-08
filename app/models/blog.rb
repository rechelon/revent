class Blog < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :title, :body, :event_id
end
