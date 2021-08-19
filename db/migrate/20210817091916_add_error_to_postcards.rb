class AddErrorToPostcards < ActiveRecord::Migration[6.1]
  def change
    remove_column :card_orders, :send_delay, :integer
    add_column :postcards, :error, :string, null: true, default: nil
  end
end
