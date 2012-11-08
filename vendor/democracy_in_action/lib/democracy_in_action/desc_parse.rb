require 'rexml/document'
require 'rexml/streamlistener'

#include REXML

module DemocracyInAction
  # a parser just for the table descriptions
  # call result() to get an Array of FieldDesc
  class DIA_Desc_Listener #:nodoc:
    include REXML::StreamListener

    def initialize
      @fields = Array.new
      @key = nil
      @tmp = nil
    end

    def tag_start(name, attributes)
      case name
      when 'Field'
        @fields << Result.new(@tmp) if @tmp;
        @tmp = Hash.new
        @key = name.downcase
      when 'Type', 'Null', 'Key', 'Default', 'Extra'
        @key = name.downcase
      end
    end

    def tag_end(name)
      @key = nil
      # and a hack so the last field gets added anyway...
      @fields << Result.new(@tmp) if (name == "data")
    end

    def text(text)
      @tmp[@key] = text if @key
    end

    # returns - Array of FieldDesc
    def result()
      Hash[*@fields.map { |item| [ item.field.to_sym, item ] }.flatten ]
    end

  end
end
