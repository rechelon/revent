class Hostform < ActiveRecord::Base
	belongs_to :calendar
	belongs_to :site
	has_one :trigger
end
