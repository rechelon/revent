module DemocracyInAction
  module Validations
    REQUIRED_FIELDS = [:First_Name, :Last_Name, :Email, :Phone, :Street, :City, :State, :Zip]
    def self.included(base)
      base.send(:include, ActiveRecord::Validations)
#      base.send(:validates_presence_of, *REQUIRED_FIELDS)
#      base.alias_method_chain :save, :validation
    end


    def save_with_validation
      validates
      save_without_validation
    end
  end
end
