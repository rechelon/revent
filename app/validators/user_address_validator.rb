class UserAddressValidator < ActiveModel::Validator
  def validate user
    if User.full_address_required? and (user.street.blank? or user.city.blank?)
      user.errors.add :address, "Street address and/or city (required) are blank"
    end
  end
end
