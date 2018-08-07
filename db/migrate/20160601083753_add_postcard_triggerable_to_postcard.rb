class AddPostcardTriggerableToPostcard < ActiveRecord::Migration[4.2]
  def change
    add_column :postcards, :postcard_triggerable_id, :integer
    add_column :postcards, :postcard_triggerable_type, :string
  end
end
