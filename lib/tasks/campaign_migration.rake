desc "Migrate filter"
task :migrate_filters => :environment do
  ActiveRecord::Base.transaction do
    CardOrder.find_each do |cp|
      old_filter = cp.filters.last

      filter_data = {"accepted"=> {
          "number_of_order" =>{"condition"=>"matches_number", "value"=>1},
        }, "removed"=>{}}

      if old_filter.present?
        min = old_filter.filter_data["minimum"].to_i || -1.0
        max = old_filter.filter_data["maximum"].to_i.positive? ? old_filter.filter_data["maximum"].to_i : 1_000_000_000
        cp.filters.destroy_all

        if old_filter.filter_data["minimum"].present? && old_filter.filter_data["maximum"].present?
          if min != 0 && max == 99999
            filter_data["accepted"]["last_order_total"] = {"condition"=>"greater_number", "value"=>min.to_s}
          elsif min == 0 && max != 99999
            filter_data["accepted"]["last_order_total"] = {"condition"=>"smaller_number", "value"=>max.to_s}
          elsif min != 0 && max != 99999
            filter_data["accepted"]["last_order_total"] = {"condition"=>"between_number", "value"=>"#{min}&#{max}"}
          end
        elsif old_filter.filter_data["minimum"].present? && min != 0
          filter_data["accepted"]["last_order_total"] = {"condition"=>"greater_number", "value"=>min.to_s}
        elsif old_filter.filter_data["maximum"].present?
          filter_data["accepted"]["last_order_total"] = {"condition"=>"smaller_number", "value"=>max.to_s}
        end
      end

      Filter.create(card_order_id: cp.id, filter_data: filter_data)
    end
  end
end

desc "Migrate start date for campaigns"
task :migrate_start_date_of_campaigns => :environment do
  CardOrder.find_each do |cp|
    cp.send_date_start = Date.current
    cp.send_continuously = true
    cp.campaign_status = :sending if cp.enabled?
    cp.save
  end
end
