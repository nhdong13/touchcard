class UpdateLastMonth < ActiveRecord::Migration
  def up
    Shop.all.each do |shop|
      shop.get_last_month
    end
  end
end
