class AddPaidToPostcard < ActiveRecord::Migration[4.2]
  def change
    add_column :postcards, :paid, :boolean, default: false, null: false
  end
end
