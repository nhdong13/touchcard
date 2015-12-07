class RefactorPostcards < ActiveRecord::Migration
  def up
    change_table :postcards do |t|
      t.belongs_to :customer, index: true, foreign_key: true
      t.belongs_to :order, index: true, foreign_key: true
    end
    execute("
      DELETE FROM postcards WHERE id IN (
        SELECT min(id) FROM postcards
        GROUP BY triggering_shopify_order_id
        HAVING count(*) > 1
      );
    ")

    Shop.all.each do |shop|
      shop.new_sess
      shop.postcards.each do |postcard|
        begin
          shopify_order = ShopifyAPI::Order.find(postcard.triggering_shopify_order_id)
        rescue
          wait 2
          retry
        end
        order = Order.from_shopify!(shopify_order)
        postcard.update_attributes!(customer: order.customer, order: order)
      end
    end

    change_table :postcards do |t|
      t.remove :customer_name
      t.remove :addr1
      t.remove :addr2
      t.remove :city
      t.remove :state
      t.remove :country
      t.remove :zip
      t.remove :shopify_customer_id
      t.remove :triggering_shopify_order_id
      t.remove :purchase2
      t.remove :return_customer
    end
  end
end
