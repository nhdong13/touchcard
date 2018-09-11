class RenameTriggerableToTrigger < ActiveRecord::Migration[5.1]
  def change
    rename_column :postcards, :postcard_triggerable_id, :postcard_trigger_id
    rename_column :postcards, :postcard_triggerable_type, :postcard_trigger_type
  end
end
