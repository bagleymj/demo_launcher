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

ActiveRecord::Schema.define(version: 20170116163152) do

  create_table "accounts", force: :cascade do |t|
    t.string   "access_key_id"
    t.string   "secret_access_key"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "region"
  end

  create_table "companies", force: :cascade do |t|
    t.string   "company_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "instances", force: :cascade do |t|
    t.string   "instance_id"
    t.integer  "stack_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "stacks", force: :cascade do |t|
    t.string   "stack_id"
    t.string   "stack_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "template_id"
    t.integer  "company_id"
  end

  add_index "stacks", ["template_id"], name: "index_stacks_on_template_id"

  create_table "templates", force: :cascade do |t|
    t.string   "template_name"
    t.string   "template_url"
    t.integer  "account_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "templates", ["account_id"], name: "index_templates_on_account_id"

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "display_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.boolean  "admin"
    t.integer  "company_id"
  end

end
