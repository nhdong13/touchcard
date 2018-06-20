<<<<<<< HEAD
class AddCanceledToPostcards < ActiveRecord::Migration[4.2]
=======
class AddCanceledToPostcards < ActiveRecord::Migration
>>>>>>> old-app-with-node-stub
  def change
    add_column :postcards, :canceled, :boolean, default: false
  end
end
