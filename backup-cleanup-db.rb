
Shop.where.not(id: [1857,1845,1833,1893,1829,1896]).each do |shop|
  shop.subscriptions.destroy_all
  cus_ids = shop.orders.pluck(:customer_id).compact.join(",")
  shop.orders.where.not(postcard_id: nil).update_all(postcard_id: nil)
  ActiveRecord::Base.connection.execute("delete from postcards where postcards.id in (#{shop.postcards.pluck(:id).join(',')})") if shop.postcards.present?
  ids = ActiveRecord::Base.connection.exec_query("Select id from orders where orders.shop_id = #{shop.id}").rows.flatten
  ids.in_groups_of(2000, false) do |idg|
    idg_string = idg.join(',')
    ActiveRecord::Base.connection.execute("delete from line_items where line_items.order_id in (#{idg_string});delete from postcards where postcards.postcard_trigger_id in (#{idg_string});delete from orders where orders.id in (#{idg_string})")
  end
  unless cus_ids.empty?
    cus_ids.in_groups_of(2000, false) do |idg|
      idg_string = idg.join(',')
      ActiveRecord::Base.connection.execute("delete from addresses where addresses.customer_id in (#{idg_string})")
      ActiveRecord::Base.connection.execute("delete from customers where customers.id in (#{idg_string})")
    end
  end
  shop.card_orders.unscope(where: :archived).destroy_all
  shop.destroy
end

Customer.find_each do |cus|
  if cus.orders.count == 0 
    ActiveRecord::Base.connection.execute("delete from addresses where addresses.customer_id = #{cus.id}")
    cus.destroy
  end
end

ids = Order.pluck(:customer_id)
Customer.where.not(id: ids).find_each{|c|c.destroy}
ActiveRecord::Base.connection.execute("delete from addresses where addresses.customer_id in (1265117, 1265118, 1265119, 1265121, 1265122, 1265123, 1265124, 1265125, 1265126, 1265127, 1265128, 1265129, 1265131, 1265132, 1265133, 1265134, 1265135, 1265136, 1269606, 1265137, 1265139, 1265140, 1269607, 1265141, 1265142, 1265145, 1265146, 1265147, 1265148, 1265149, 1265150, 1265151, 1265152, 1265153, 1265155, 1265158, 1265159, 1265162, 1265163, 1265164, 1265165, 1265166, 1265168, 1265167, 1265170, 1265171, 1265172, 1265173, 1265174, 1265161)")
ActiveRecord::Base.connection.execute("delete from customers where customers.id in (1265117, 1265118, 1265119, 1265121, 1265122, 1265123, 1265124, 1265125, 1265126, 1265127, 1265128, 1265129, 1265131, 1265132, 1265133, 1265134, 1265135, 1265136, 1269606, 1265137, 1265139, 1265140, 1269607, 1265141, 1265142, 1265145, 1265146, 1265147, 1265148, 1265149, 1265150, 1265151, 1265152, 1265153, 1265155, 1265158, 1265159, 1265162, 1265163, 1265164, 1265165, 1265166, 1265168, 1265167, 1265170, 1265171, 1265172, 1265173, 1265174, 1265161)")



Postcard.where("send_date > '2021-08-14 0:0:0' and send_date < '2021-08-17 0:0:0'")
Postcard.where("date_sent > '2021-08-14 0:0:0' and date_sent < '2021-08-17 0:0:0'")
