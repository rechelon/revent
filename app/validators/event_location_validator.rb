class EventLocationValidator < ActiveModel::Validator

  def validate event
    validate_city event 
    validate_country_code event 
    validate_postal_code event
    validate_state event 
    validates_mappable event
  end

private
  def validate_postal_code event
    if event.in_usa?
      unless event.postal_code =~ /^\d{5}(-\d{4})?$/
        errors.add :postal_code, "is not a valid U.S. postal code"
      end
    elsif event.in_canada?
      unless event.postal_code =~ /^\D\d\D((-| )?\d\D\d)?$/
        errors.add :postal_code, "is not a valid Canadian postal code"
      end
    end      
  end

  def validate_city event
    errors.add "City is blank" unless event.city
  end

  def validate_country_code event
    errors.add "Country is blank" unless event.country_code 
  end

  def validate_state event
    if event.in_usa?
      valid_us_states = DemocracyInAction::Helpers.state_options_for_select.map{|a| a[1]}
      if event.state.blank? or not valid_us_states.include?(event.state)
        errors.add :state, "is not a valid U.S. state"
      end      
    elsif event.in_canada?
      unless event.state_is_canadian_province?
        errors.add :state, "is not a valid Canadian province"
      end
    end
  end

  def validates_mappable event
    # only check that usa and canadian events are mappable
    if (event.in_usa? || event.in_canada?) && !(event.latitude && event.longitude)
      errors.add_to_base "Not enough information provided to place event on a map. Please give us at minimum a valid postal code."
    end
  end

end
