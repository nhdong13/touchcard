class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.belongs_to  :shop
      t.string      :template
      t.string      :logo
      t.string      :image_front
      t.string      :image_back
      t.string      :text_front
      t.string      :title_back
      t.string      :text_back
      t.string      :coupon
      t.string      :customer_name
      t.bigint      :customer_id
      t.string      :addr1
      t.string      :addr2
      t.string      :city
      t.string      :state
      t.string      :country
      t.string      :zip
      t.datetime    :send_date
      t.boolean     :sent, null: false, default: false
      t.datetime    :date_sent
      t.bigint      :postcard_id

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :cards
  end
end
