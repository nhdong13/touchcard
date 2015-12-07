class Address < ActiveRecord::Base
  belongs_to :customer

  class << self
    def from_shopify!(address)
      create_attrs = address.attributes.with_indifferent_access.slice(
        :address1,
        :address2,
        :city,
        :company,
        :country,
        :country_code,
        :first_name,
        :last_name,
        :latitude,
        :phone,
        :province,
        :zip,
        :name,
        :text,
        :province_code).merge(shopify_id: address.id)
      inst = find_by(shopify_id: address.id)
      return create!(create_attrs) unless inst
      inst.update_attributes!(create_attrs)
      inst
    end
  end

  def to_lob_address
    {
      name: name,
      address_line1: address1,
      address_line2: address2,
      address_city: city,
      address_state: state,
      address_country: country,
      address_zip: zip
    }
  end
end
