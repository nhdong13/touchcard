class CustomersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    require 'customer_check'
    bulk_template = record.card_template

    amount = get_customer_number(record.shop_id, bulk_temlate.customers_after, bulk_template.customers_before)

    unless value == amount
      record.errors[attribute] << (options[:message] || "Customer amount error")
    end

  end
end
