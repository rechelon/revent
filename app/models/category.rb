class Category < ActiveRecord::Base
  has_many :events
  belongs_to :site
  belongs_to :calendar
end
