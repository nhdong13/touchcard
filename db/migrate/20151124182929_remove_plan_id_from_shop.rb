class RemovePlanIdFromShop < ActiveRecord::Migration
  def change
    remove_reference :shops, :plan
  end
end
