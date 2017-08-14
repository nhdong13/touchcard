class AddPostcardTriggerableToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :postcard_triggerable_id, :integer
    add_column :postcards, :postcard_triggerable_type, :string
  end
end
