# TODO: And now do this - finish testing the checkout / postcard / redemption numbers
# Convince myself that they work + only linked postcards are getting counted 

# TODO: Somehow got to https://ngrokcard.myshopify.com/admin/apps/touchcard-dev-ngrok/subscriptions
# After subscribing / creating / setting up postcard. It's missing a template/view, so threw an error.

#TODO: Revenue generation
    So the order.joins method doesn't work, because it uses both relations


## TODO: Check / Fix revenue attribution. On Development (with sample data) it still looks messed up.
## It should only count the explicitly linked cards



---

TODO: 

CardAttributes::showsDiscount()

resets coupon location to 40/60...

this works in the UI, but fails on rendering


is there a way we can maintain discount_x and discount_y or does the disappearance of the coupon automatically nuke these in the UI version?


if so, what can we do to make sure that 40/60 doesn't overwrite the actual values when this gets rendered via postcard_render_pack.js?




---
TODO:

We've got the NaN rendering fixed, but now the coupon disappears when editing the postcard...


So this last line in card_side.vue

        <discount-element :discount_x.sync="attributes.discount_x"
                          :discount_y.sync="attributes.discount_y"
                          :discount_pct="discount_pct"
                          :discount_exp="discount_exp"
                          :discount_code="discount_code"
                          v-if="this.attributes.showsDiscount && discount_exp && discount_pct && discount_code"
                          >

needs to be adjusted so it's safe for rendering AND editing


and make sure these tests are complete: 

postcard_render_controller_spec

postcard_render_util_spec

---

TODO:

Figure out what configuration of 
:postcard / :card_order / etc 
is making these render properly via postcard_render_util_spec.rb but not postcard_render_controller.spec.rb?

Get this working in postcard_render_controller.spec.rb
to test the HTML directly



#<Postcard id: 465, card_order_id: 627, discount_code: "XXX-YYY-ZZZ", send_date: nil, sent: false, date_sent: nil, postcard_id: nil, created_at: "2019-11-15 11:37:37", updated_at: "2019-11-15 11:37:37", customer_id: 453, postcard_trigger_id: 634, paid: true, estimated_arrival: nil, arrival_notification_sent: false, postcard_trigger_type: "Order", expiration_notification_sent: false, discount_pct: -37, discount_exp_at: "1990-01-24 00:00:00", price_rule_id: nil, canceled: false>



#<CardOrder id: 625, shop_id: 1194, type: "PostSaleOrder", discount_pct: -37, discount_exp: 2, enabled: true, international: false, send_delay: 2, arrive_by: nil, customers_before: nil, customers_after: nil, status: nil, created_at: "2019-11-15 11:29:05", updated_at: "2019-11-15 11:29:05", winback_delay: nil, lifetime_purchase_threshold: nil, archived: false, front_json: {"version"=>0, "background_url"=>"/Users/dustin/code/touchcard/api/spec/images/background_1.jpg", "discount_x"=>376, "discount_y"=>56}, back_json: {"version"=>0, "background_url"=>"/Users/dustin/code/touchcard/api/spec/images/background_2.jpg", "discount_x"=>nil, "discount_y"=>nil}>


---



TODO: The Errors in log about 
	`Expected discount code during rendering`
	shouldn't have appeared. The card_orders did not have discount_pct / discount_exp, so shouldn't have had a discount.

	Make sure that the new code works and successfully sends those 
	66 
	cards that did not go out on staging.


https://papertrailapp.com/groups/2563514/events?q=Expected%20discount%20code%20during%20rendering&focus=1111090028078678025



