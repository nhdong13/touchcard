# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_03_150657) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.text "address1"
    t.text "address2"
    t.text "city"
    t.text "company"
    t.text "country"
    t.string "country_code"
    t.string "first_name"
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.text "phone"
    t.text "province"
    t.text "zip"
    t.string "name"
    t.string "text"
    t.string "province_code"
    t.boolean "default"
    t.bigint "shopify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
    t.index ["customer_id"], name: "index_addresses_on_customer_id"
    t.index ["shopify_id"], name: "index_addresses_on_shopify_id", unique: true
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "card_orders", id: :serial, force: :cascade do |t|
    t.integer "shop_id"
    t.string "type"
    t.integer "discount_pct"
    t.integer "discount_exp"
    t.boolean "enabled", default: false, null: false
    t.boolean "international", default: false, null: false
    t.integer "send_delay", default: 2
    t.datetime "arrive_by"
    t.datetime "customers_before"
    t.datetime "customers_after"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "winback_delay"
    t.integer "lifetime_purchase_threshold"
    t.boolean "archived", default: false
    t.json "front_json", default: {}
    t.json "back_json", default: {}
    t.json "price_rules", default: {}
  end

  create_table "card_sides", id: :serial, force: :cascade do |t|
    t.text "image"
    t.text "preview"
    t.boolean "is_back", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discount_y"
    t.integer "discount_x"
    t.bigint "card_order_id"
    t.index ["card_order_id"], name: "index_card_sides_on_card_order_id"
  end

  create_table "charges", id: :serial, force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "card_order_id", null: false
    t.bigint "shopify_id"
    t.integer "amount", null: false
    t.boolean "recurring", default: false, null: false
    t.text "status", default: "new", null: false
    t.string "shopify_redirect"
    t.text "last_page", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "token", null: false
  end

  create_table "checkouts", id: :serial, force: :cascade do |t|
    t.bigint "shopify_id", null: false
    t.integer "shop_id"
    t.integer "customer_id"
    t.string "abandoned_checkout_url", null: false
    t.string "cart_token", null: false
    t.datetime "closed_at"
    t.datetime "completed_at"
    t.string "token", null: false
    t.decimal "total_price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_line_items_price"
    t.index ["customer_id"], name: "index_checkouts_on_customer_id"
    t.index ["shop_id"], name: "index_checkouts_on_shop_id"
    t.index ["shopify_id"], name: "index_checkouts_on_shopify_id", unique: true
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.bigint "shopify_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.boolean "verified_email"
    t.integer "total_spent"
    t.boolean "tax_exempt"
    t.text "tags"
    t.string "state"
    t.integer "orders_count"
    t.text "note"
    t.text "last_order_name"
    t.string "last_order_id"
    t.boolean "accepts_marketing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shopify_id"], name: "index_customers_on_shopify_id", unique: true
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "filters", id: :serial, force: :cascade do |t|
    t.integer "card_order_id"
    t.text "filter_data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_order_id"], name: "index_filters_on_card_order_id"
  end

  create_table "gdpr_customers_data_requests", id: :serial, force: :cascade do |t|
    t.bigint "shop_shopify_id"
    t.string "shop_domain"
    t.bigint "customer_shopify_id"
    t.string "customer_email"
    t.string "customer_phone"
    t.bigint "orders_requested", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gdpr_customers_redacts", id: :serial, force: :cascade do |t|
    t.bigint "shop_shopify_id"
    t.string "shop_domain"
    t.bigint "customer_shopify_id"
    t.string "customer_email"
    t.string "customer_phone"
    t.bigint "orders_to_redact", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gdpr_shop_redacts", id: :serial, force: :cascade do |t|
    t.bigint "shop_shopify_id"
    t.string "shop_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_items", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "fulfillable_quantity"
    t.string "fulfillment_service"
    t.string "fulfillment_status"
    t.integer "grams"
    t.bigint "shopify_id", null: false
    t.string "price"
    t.bigint "product_id"
    t.integer "quantity"
    t.boolean "requires_shipping"
    t.string "sku"
    t.string "title"
    t.bigint "variant_id"
    t.string "variant_title"
    t.string "vendor"
    t.string "name", null: false
    t.boolean "gift_card"
    t.boolean "taxable"
    t.string "total_discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["shopify_id"], name: "index_line_items_on_shopify_id", unique: true
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.bigint "shopify_id", null: false
    t.string "browser_ip"
    t.text "discount_codes"
    t.string "financial_status"
    t.string "fulfillment_status"
    t.text "tags"
    t.text "landing_site"
    t.text "referring_site"
    t.integer "total_discounts"
    t.integer "total_line_items_price"
    t.integer "total_price", null: false
    t.integer "total_tax", null: false
    t.string "processing_method"
    t.datetime "processed_at"
    t.integer "customer_id"
    t.integer "billing_address_id"
    t.integer "shipping_address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "postcard_id"
    t.integer "shop_id", null: false
    t.index ["billing_address_id"], name: "index_orders_on_billing_address_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["postcard_id"], name: "index_orders_on_postcard_id"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address_id"
    t.index ["shop_id"], name: "index_orders_on_shop_id"
    t.index ["shopify_id"], name: "index_orders_on_shopify_id", unique: true
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.integer "amount", null: false
    t.string "interval", default: "month", null: false
    t.string "name", null: false
    t.string "currency", default: "usd", null: false
    t.integer "interval_count", default: 1, null: false
    t.boolean "on_stripe", default: false, null: false
    t.integer "trial_period_days"
    t.text "statement_descriptor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "postcards", id: :serial, force: :cascade do |t|
    t.integer "card_order_id"
    t.string "discount_code"
    t.datetime "send_date"
    t.boolean "sent", default: false, null: false
    t.datetime "date_sent"
    t.string "postcard_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
    t.integer "postcard_trigger_id"
    t.boolean "paid", default: false, null: false
    t.datetime "estimated_arrival"
    t.boolean "arrival_notification_sent", default: false, null: false
    t.string "postcard_trigger_type"
    t.boolean "expiration_notification_sent", default: false
    t.integer "discount_pct"
    t.datetime "discount_exp_at"
    t.bigint "price_rule_id"
    t.boolean "canceled", default: false
    t.index ["customer_id"], name: "index_postcards_on_customer_id"
    t.index ["postcard_trigger_id"], name: "index_postcards_on_postcard_trigger_id"
  end

  create_table "shops", id: :serial, force: :cascade do |t|
    t.string "domain", null: false
    t.string "token", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "shopify_id"
    t.integer "credit", default: 0
    t.bigint "webhook_id"
    t.bigint "uninstall_id"
    t.integer "charge_amount", default: 0
    t.datetime "charge_date"
    t.integer "customer_pct", default: 100
    t.integer "last_month"
    t.boolean "send_next", default: true, null: false
    t.datetime "last_login"
    t.string "stripe_customer_id"
    t.string "name"
    t.string "email"
    t.string "customer_email"
    t.string "plan_name"
    t.string "owner"
    t.datetime "shopify_created_at"
    t.datetime "shopify_updated_at"
    t.string "approval_state", default: "new", null: false
    t.datetime "uninstalled_at"
    t.datetime "last_login_at"
    t.json "metadata", default: {}
    t.text "oauth_scopes"
    t.index ["domain"], name: "index_shops_on_domain", unique: true
  end

  create_table "stripe_events", id: :serial, force: :cascade do |t|
    t.string "stripe_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "quantity", null: false
    t.integer "plan_id"
    t.integer "shop_id"
    t.datetime "current_period_start", null: false
    t.datetime "current_period_end", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_id", null: false
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["shop_id"], name: "index_subscriptions_on_shop_id"
    t.index ["stripe_id"], name: "index_subscriptions_on_stripe_id"
  end

  add_foreign_key "addresses", "customers"
  add_foreign_key "card_orders", "shops"
  add_foreign_key "card_sides", "card_orders"
  add_foreign_key "charges", "card_orders"
  add_foreign_key "charges", "shops"
  add_foreign_key "checkouts", "customers"
  add_foreign_key "checkouts", "shops"
  add_foreign_key "filters", "card_orders"
  add_foreign_key "line_items", "orders"
  add_foreign_key "orders", "addresses", column: "billing_address_id"
  add_foreign_key "orders", "addresses", column: "shipping_address_id"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "postcards"
  add_foreign_key "orders", "shops"
  add_foreign_key "postcards", "card_orders"
  add_foreign_key "postcards", "customers"
  add_foreign_key "postcards", "orders", column: "postcard_trigger_id"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "shops"
end
