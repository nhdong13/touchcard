desc "Sync local version of shops information with latest from shopify"
task :sync_shopify_metadata => :environment do
  Shop.all.each do |shop|
    begin
      shop.new_sess
      shop.sync_shopify_metadata
    rescue
      next
    end
  end
end
