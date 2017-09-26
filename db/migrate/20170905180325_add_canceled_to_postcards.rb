class AddCanceledToPostcards < ActiveRecord::Migration
  def change
    add_column :postcards, :canceled, :boolean, default: false
  end
end
