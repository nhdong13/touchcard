class AddTokenToCharges < ActiveRecord::Migration[4.2]
  def change
    add_column :charges, :token, :text, null: false
  end
end
