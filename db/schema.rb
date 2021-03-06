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

ActiveRecord::Schema.define(version: 20180519231207) do

  create_table "homes", force: :cascade do |t|
    t.text     "searchQ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "magic_cards", force: :cascade do |t|
    t.integer  "productID"
    t.string   "name"
    t.float    "tcgPrice"
    t.float    "ckPrice"
    t.boolean  "isFoil"
    t.string   "set"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "spread"
  end

  create_table "magic_sets", force: :cascade do |t|
    t.string   "setName"
    t.integer  "tcgID"
    t.integer  "ckID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "sdkID"
  end

end
