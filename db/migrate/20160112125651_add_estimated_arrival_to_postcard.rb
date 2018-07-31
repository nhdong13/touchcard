class AddEstimatedArrivalToPostcard < ActiveRecord::Migration[4.2]
  def change
    add_column :postcards, :estimated_arrival, :timestamp
  end
end
