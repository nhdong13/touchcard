desc "Migrate filter"
task :migrate_filters => :environment do
  ActiveRecord::Base.transaction do
    CardOrder.find_each do |cp|
      old_filter = cp.filters.last
      min = filter.filter_data["minimum"].to_f || -1.0
      max = filter.filter_data["maximum"].to_f.positive? ? filter.filter_data["maximum"].to_f : 1_000_000_000.0
      cp.filters.destroy_all
      if filter.filter_data["maximum"].present?
        Filter.create(card_order_id: cp.id,
          filter_data: {"accepted"=> {
            "number_of_order" =>{"condition"=>"matches_number", "value"=>1},
            "last_order_total"=>{"condition"=>"smaller_number", "value"=>max}
          }, "removed"=>{}})
      else
        Filter.create(card_order_id: cp.id,
          filter_data: {"accepted"=> {
            "number_of_order" =>{"condition"=>"matches_number", "value"=>1},
            "last_order_total"=>{"condition"=>"greater_number", "value"=>min}
          }, "removed"=>{}})
      end
    end
  end
end

desc "Migrate start date for campaigns"
task :migrate_start_date_of_campaigns => :environment do
  CardOrder.find_each do |cp|
    cp.enabled = true
    cp.send_date_start = Date.current
    cp.send_continuously = true
    cp.campaign_status = :sending
    cp.save!
  end
end
