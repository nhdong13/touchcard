class CustomersValidator < ActiveModel::EachValidator

  def validate(record, attribute, value)
    unless record.recurring?
      require 'customer_check'
      bulk_template = record.card_template
      amount = get_customer_number(record.shop_id, bulk_temlate.customers_after, bulk_template.customers_before)

      unless value == amount
        record.errors[:amount] << "Customers amount error"
      end
    end
  end
end
