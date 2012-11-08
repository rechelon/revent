class EventsSponsor < ActiveRecord::Base
  has_many :events
  has_many :sponsors
end
