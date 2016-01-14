class AddEstimatedArrivalToPostcard < ActiveRecord::Migration
  def change
    add_column :postcards, :estimated_arrival, :timestamp
  end
end
