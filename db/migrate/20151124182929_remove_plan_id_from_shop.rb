class RemovePlanIdFromShop < ActiveRecord::Migration[4.2]
  def change
    remove_reference :shops, :plan
  end
end
