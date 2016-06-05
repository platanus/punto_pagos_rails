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

ActiveRecord::Schema.define(version: 20160602004614) do

  create_table "punto_pagos_rails_transactions", force: :cascade do |t|
    t.integer  "payable_id"
    t.string   "payable_type", limit: 255
    t.string   "token",        limit: 255
    t.integer  "amount"
    t.string   "error",        limit: 255
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "punto_pagos_rails_transactions", ["payable_id", "payable_type"], name: "index_punto_pagos_rails_transactions_on_payable", unique: true

  create_table "tickets", force: :cascade do |t|
    t.integer  "amount"
    t.string   "message",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
