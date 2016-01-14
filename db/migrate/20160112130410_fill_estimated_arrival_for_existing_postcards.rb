class FillEstimatedArrivalForExistingPostcards < ActiveRecord::Migration
  def up
    Postcard.where(sent: true).each do |postcard|
      eta = postcard.estimated_transit_days.business_days.after(postcard.send_date)
      postcard.update_attributes(estimated_arrival: eta)
    end
  end

  def down
    Postcard.update_all(estimated_arrival: nil)
  end
end
