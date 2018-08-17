class FixPostcardTriggerableReference < ActiveRecord::Migration[5.1]
  def up
    remove_column :postcards, :postcard_triggerable_id
    rename_column :postcards, :order_id, :postcard_triggerable_id
    Postcard.update_all(postcard_triggerable_type: 'Order')
  end

  def down
    rename_column :postcards, :postcard_triggerable_id, :order_id
    # Could do this, but it'll get deleted anyway by subsequent down migration
    # Postcard.update_all(postcard_triggerable_type: nil)
  end
end
