require "customer_check"
class CustomersValidator < ActiveModel::EachValidator
  def validate(record, _attribute, value)
    unless record.recurring?
      bulk_template = record.card_order
      amount = CustomerCheck.get_customer_number(record.shop_id, bulk_temlate.customers_after, bulk_template.customers_before)

      record.errors[:amount] << "Customers amount error" unless value == amount
    end
  end
end
