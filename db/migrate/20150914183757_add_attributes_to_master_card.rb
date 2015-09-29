class AddAttributesToMasterCard < ActiveRecord::Migration
  def up
    add_column :master_cards, :template,       :string
    add_column :master_cards, :logo,           :string
    add_column :master_cards, :image_front,    :string
    add_column :master_cards, :image_back,     :string
    add_column :master_cards, :title_front,    :string
    add_column :master_cards, :text_front,     :string
    add_column :master_cards, :text_back,      :string
    add_column :master_cards, :preview_front,  :string
    add_column :master_cards, :preview_back,   :string
    add_column :master_cards, :coupon_pct,     :int
    add_column :master_cards, :coupon_exp,     :int
    add_column :master_cards, :coupon_loc,     :string
  end

  def down
    remove_column :master_cards, :template
    remove_column :master_cards, :logo
    remove_column :master_cards, :image_front
    remove_column :master_cards, :image_back
    remove_column :master_cards, :title_front
    remove_column :master_cards, :text_front
    remove_column :master_cards, :text_back
    remove_column :master_cards, :preview_front
    remove_column :master_cards, :preview_back
    remove_column :master_cards, :coupon_pct
    remove_column :master_cards, :coupon_exp
    remove_column :master_cards, :coupon_loc
  end
end
