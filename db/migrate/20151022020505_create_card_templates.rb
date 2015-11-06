class CreateCardTemplates < ActiveRecord::Migration
  def change
    create_table(:card_templates) do |t|
      t.belongs_to  :shop
      t.string      :type
      t.string      :style
      t.string      :logo
      t.string      :image_front
      t.string      :image_back
      t.string      :logo
      t.string      :title_front
      t.string      :text_front
      t.string      :preview_front
      t.string      :preview_back
      t.integer     :coupon_pct
      t.integer     :coupon_exp
      t.string      :coupon_loc
      t.boolean     :enabled, null: false, default: false
      t.boolean     :international, null: false, default: false
      t.integer     :send_delay
      t.datetime    :arrive_by
      t.datetime    :customers_before
      t.datetime    :customers_after
      t.bigint      :transaction_id
      t.string      :status
      t.integer     :cards_sent
      t.float       :revenue

      t.timestamps  null: false
    end
  end
end
