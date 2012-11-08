require 'ostruct'
require 'forwardable'
module DemocracyInAction
  # Requests which return XML will be converted into an array of DemocracyInAction::Results
  #
  # Data in a Result can be accessed via Result#[field_name], ie result.Group_Name
  # 
  # This data may also be accessed as a hash, ie result.each { |key, value| puts value } or result[:Group_Name]
  class Result < OpenStruct
    extend Forwardable
    def_delegators :@table, *Enumerable.instance_methods
    # access a single field with a string or symbol key
    def [](key)
      @table[key.to_sym]
    end
    # set the value of a field with a string or symbol key
    def []=(key, value)
      @table[key.to_sym] = value
    end
    # returns the Result as a Hash
    def to_h
      @table
    end
  end
end
