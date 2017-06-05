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

ActiveRecord::Schema.define(version: 20170605020823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ingredients", force: :cascade do |t|
    t.string   "item"
    t.string   "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item"], name: "index_ingredients_on_item", using: :btree
  end

  create_table "lockdays", force: :cascade do |t|
    t.date     "day"
    t.boolean  "locked"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_lockdays_on_day", using: :btree
    t.index ["user_id"], name: "index_lockdays_on_user_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "shop_id"
    t.date     "day"
    t.integer  "quantity"
    t.boolean  "locked"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_orders_on_day", using: :btree
    t.index ["product_id", "shop_id", "day"], name: "index_orders_on_product_id_and_shop_id_and_day", unique: true, using: :btree
    t.index ["product_id"], name: "index_orders_on_product_id", using: :btree
    t.index ["shop_id"], name: "index_orders_on_shop_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "leadtime"
    t.decimal  "price",       precision: 8, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "recipes", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "ingredient_id"
    t.integer  "amount"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["ingredient_id"], name: "index_recipes_on_ingredient_id", using: :btree
    t.index ["product_id", "ingredient_id"], name: "index_recipes_on_product_id_and_ingredient_id", unique: true, using: :btree
    t.index ["product_id"], name: "index_recipes_on_product_id", using: :btree
  end

  create_table "shops", force: :cascade do |t|
    t.string   "name"
    t.text     "address"
    t.string   "suburb"
    t.string   "postcode"
    t.string   "contact"
    t.string   "phone"
    t.string   "email"
    t.text     "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "role"
    t.date     "day"
    t.string   "shop"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "lockdays", "users"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "shops"
  add_foreign_key "orders", "users"
  add_foreign_key "recipes", "ingredients"
  add_foreign_key "recipes", "products"
end
