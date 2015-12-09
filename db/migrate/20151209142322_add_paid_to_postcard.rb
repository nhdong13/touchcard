class AddPaidToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :paid, :boolean, default: false, null: false
  end
end
