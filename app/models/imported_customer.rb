class ImportedCustomer < ApplicationRecord
  belongs_to :card_order
  has_one :postcard

  validates :card_order_id, :name, :address1, :city, :province_code, :country_code, :zip, presence: true

  def self.import_csv(file_url, campaign_id)
    imported_customers = []

    spreadsheet = Roo::Spreadsheet.open(file_url)
    spreadsheet_rows = spreadsheet.parse(name: "Name", address1: "Address1", address2: "Address2", city: "City", province_code: "Province/State Code", country_code: "Country Code", zip: "Zip/Postal Code")
    spreadsheet_rows.each do |row|
      next unless row[:name].present? &&
                  row[:address1].present? &&
                  row[:city].present? &&
                  row[:province_code].present? &&
                  row[:country_code].present? &&
                  row[:zip].present?
      
      customer = ImportedCustomer.new(
        name: row[:name],
        address1: row[:address1],
        address2: row[:address2].present? ? row[:address2] : "",
        city: row[:city],
        province_code: row[:province_code].upcase,
        country_code: row[:country_code].upcase,
        zip: row[:zip],
        card_order_id: campaign_id
      )
      
      imported_customers << customer
    end

    ImportedCustomer.import imported_customers
  end

  def international?
    country_code.present? && country_code != "US"
  end

  def to_lob_address
    {
      name: name[0...50],
      address_line1: address1,
      address_line2: address2,
      address_city: city,
      address_state: province_code,
      address_country: country_code,
      address_zip: zip
    }
  end
end
