# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151116023011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "card_orders", force: :cascade do |t|
    t.integer  "shop_id"
    t.string   "type"
    t.integer  "discount_pct"
    t.integer  "discount_exp"
    t.boolean  "enabled",            default: false, null: false
    t.boolean  "international",      default: false, null: false
    t.integer  "send_delay"
    t.datetime "arrive_by"
    t.datetime "customers_before"
    t.datetime "customers_after"
    t.string   "status"
    t.integer  "cards_sent"
    t.float    "revenue"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "card_side_front_id",                 null: false
    t.integer  "card_side_back_id",                  null: false
  end

  create_table "card_sides", force: :cascade do |t|
    t.text     "image"
    t.text     "preview"
    t.boolean  "is_back",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "discount_y"
    t.integer  "discount_x"
  end

  create_table "charges", force: :cascade do |t|
    t.integer  "shop_id",                                    null: false
    t.integer  "card_order_id",                              null: false
    t.integer  "shopify_id",       limit: 8
    t.integer  "amount",                                     null: false
    t.boolean  "recurring",                  default: false, null: false
    t.text     "status",                     default: "new", null: false
    t.string   "shopify_redirect"
    t.text     "last_page",                                  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "token",                                      null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "postcards", force: :cascade do |t|
    t.integer  "card_order_id"
    t.string   "discount_code"
    t.integer  "triggering_shopify_order_id", limit: 8
    t.integer  "shopify_customer_id",         limit: 8
    t.string   "customer_name"
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.datetime "send_date"
    t.boolean  "sent",                                  default: false, null: false
    t.datetime "date_sent"
    t.string   "postcard_id"
    t.boolean  "return_customer",                       default: false, null: false
    t.float    "purchase2"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string   "domain",                                 null: false
    t.string   "token",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shopify_id",    limit: 8
    t.integer  "credit",                  default: 0
    t.integer  "webhook_id",    limit: 8
    t.integer  "uninstall_id",  limit: 8
    t.integer  "charge_id",     limit: 8
    t.integer  "charge_amount",           default: 0
    t.datetime "charge_date"
    t.integer  "customer_pct",            default: 100
    t.integer  "last_month"
    t.boolean  "send_next",               default: true, null: false
    t.datetime "last_login"
  end

  add_index "shops", ["domain"], name: "index_shops_on_domain", unique: true, using: :btree

  add_foreign_key "card_orders", "card_sides", column: "card_side_back_id"
  add_foreign_key "card_orders", "card_sides", column: "card_side_front_id"
  add_foreign_key "card_orders", "shops"
  add_foreign_key "charges", "card_orders"
  add_foreign_key "charges", "shops"
  add_foreign_key "postcards", "card_orders"
end
