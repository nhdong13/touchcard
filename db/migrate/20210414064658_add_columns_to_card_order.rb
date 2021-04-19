class AddColumnsToCardOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :card_orders, :name, :string
    add_column :card_orders, :campaign_status, :string
    add_column :card_orders, :budget, :integer
    add_column :card_orders, :schedule, :datetime
    CardOrder.all.each{|p| p.update(name: p.type)}
  end
end
