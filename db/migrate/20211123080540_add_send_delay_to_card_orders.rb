class AddSendDelayToCardOrders < ActiveRecord::Migration[6.1]
  def change
    # change_column_default(:card_orders, :send_delay, from: 2, to: 0)
    add_column :card_orders, :send_delay, :integer, default: 0
    #Change send delay from weeks to days
    CardOrder.where.not(send_delay: 0).find_each do |campaign|
      campaign.send_delay = campaign.send_delay * 7
      campaign.save
    end
  end
end
