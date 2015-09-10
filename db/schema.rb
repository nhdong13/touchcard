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

ActiveRecord::Schema.define(version: 20150904210020) do

  create_table "cards", force: :cascade do |t|
    t.integer  "shop_id"
    t.string   "template"
    t.string   "image_front"
    t.string   "image_back"
    t.string   "text_front"
    t.string   "text_back"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string   "domain",                  null: false
    t.string   "token",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shopify_id",    limit: 8
    t.integer  "credit"
    t.boolean  "enabled"
    t.boolean  "international"
    t.integer  "send_delay"
    t.integer  "webhook_id",    limit: 8
    t.integer  "uninstall_id",  limit: 8
  end

  add_index "shops", ["domain"], name: "index_shops_on_domain", unique: true

end
