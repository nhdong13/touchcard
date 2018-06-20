class AddCanceledToPostcards < ActiveRecord::Migration[4.2]
  def change
    add_column :postcards, :canceled, :boolean, default: false
  end
end
