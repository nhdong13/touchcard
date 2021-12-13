class AddErrorToPostcards < ActiveRecord::Migration[6.1]
  def change
    add_column :postcards, :error, :string, null: true, default: nil
  end
end
