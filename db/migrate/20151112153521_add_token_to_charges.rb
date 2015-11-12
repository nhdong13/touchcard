class AddTokenToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :token, :text, null: false
  end
end
