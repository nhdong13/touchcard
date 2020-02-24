class AddIndexToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_index :line_items, :shopify_id, unique: true
  end
end
