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

ActiveRecord::Schema.define(version: 20150921190135) do

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

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

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

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "cards", force: :cascade do |t|
    t.integer  "shop_id"
    t.string   "template"
    t.string   "logo"
    t.string   "image_front"
    t.string   "image_back"
    t.string   "text_front"
    t.string   "title_back"
    t.string   "text_back"
    t.string   "coupon"
    t.string   "customer_name"
    t.integer  "customer_id",   limit: 8
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.datetime "send_date"
    t.boolean  "sent",                    default: false, null: false
    t.datetime "date_sent"
    t.integer  "postcard_id",   limit: 8
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "master_cards", force: :cascade do |t|
    t.integer  "shop_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "template"
    t.string   "logo"
    t.string   "image_front"
    t.string   "image_back"
    t.string   "title_front"
    t.string   "text_front"
    t.string   "text_back"
    t.string   "preview_front"
    t.string   "preview_back"
    t.integer  "coupon_pct"
    t.datetime "coupon_exp"
    t.string   "coupon_loc"
  end

  create_table "shops", force: :cascade do |t|
    t.string   "domain",                                  null: false
    t.string   "token",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shopify_id",    limit: 8
    t.integer  "credit",                  default: 0
    t.boolean  "enabled",                 default: false, null: false
    t.boolean  "international",           default: false, null: false
    t.integer  "send_delay",              default: 2
    t.integer  "webhook_id",    limit: 8
    t.integer  "uninstall_id",  limit: 8
    t.integer  "customer_pct",            default: 100
    t.integer  "last_month"
    t.integer  "charge_id",     limit: 8
    t.float    "charge_amount"
    t.datetime "charge_date"
    t.boolean  "send_next",               default: true,  null: false
  end

  add_index "shops", ["domain"], name: "index_shops_on_domain", unique: true

end
