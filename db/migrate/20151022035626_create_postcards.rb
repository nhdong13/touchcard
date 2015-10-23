class CreatePostcards < ActiveRecord::Migration
  def self.up
    create_table :postcards do |t|
      t.belongs_to  :card_template
      t.string      :coupon
      t.bigint      :order_id
      t.bigint      :customer_id
      t.string      :customer_name
      t.string      :addr1
      t.string      :addr2
      t.string      :city
      t.string      :state
      t.string      :country
      t.string      :zip
      t.datetime    :send_date
      t.boolean     :sent, null: false, default: false
      t.datetime    :date_sent
      t.string      :postcard_id
      t.boolean     :return_customer, null: false, default: false
      t.float       :purchase2

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :postcards
  end
end
