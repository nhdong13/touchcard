class DisableInternationalSending < ActiveRecord::Migration[5.2]
  def self.up
    CardOrder.update_all(international: false)
  end
end
