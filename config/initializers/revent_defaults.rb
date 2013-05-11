DC = Dalli::Client.new(MEMCACHE_SERVERS)
require 'memcache_util'

ActiveRecord::Base.include_root_in_json = false
ActiveSupport.use_standard_json_time_format = false

MOLLOM_SITE = Rails.env.test? ? "http://dev.mollom.com/v1" : "http://rest.mollom.com/v1"
