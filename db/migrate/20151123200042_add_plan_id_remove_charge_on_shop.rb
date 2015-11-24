class AddPlanIdRemoveChargeOnShop < ActiveRecord::Migration
  def change
    change_table :shops do |t|
      t.remove :charge_id
      t.belongs_to :plan, index: true, foreign_key: true
    end
  end
end
