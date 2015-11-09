class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to  :shop
      t.belongs_to  :bulk_template
      t.bigint      :shopify_id
      t.float       :amount
      t.boolean     :recurring, null: false, default: false
      t.string      :status, default: "new"
      t.string      :shopify_redirect
      t.string      :last_page

      t.timestamps null: false
    end
  end
end
