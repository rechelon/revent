$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

#%w(net/http net/https).each { |f| require f }
require 'rubygems'
require 'httpclient'

require 'democracy_in_action/version'
require 'democracy_in_action/util'
require 'democracy_in_action/xml_parse'
require 'democracy_in_action/desc_parse'
require 'democracy_in_action/tables'
require 'democracy_in_action/result'
require 'democracy_in_action/api'

#legacy
=begin
class DIA_API
  def DIA_API.create(options = {})
    warn "#{caller[1]}:Warning: DIA_API.create is deprecated.  Use the gem instead"
    type = options.delete('type')
    case type
      when "default", "DIA_Simple", nil
        return DIA_API_Simple.new(options)
      else
        raise(RuntimeError, "unsupported type of DIA_API - #{type}")
    end
  end
end

class DIA_API_Simple < DemocracyInAction::API
end
=end
