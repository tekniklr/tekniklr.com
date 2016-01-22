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

ActiveRecord::Schema.define(version: 20160122044244) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "experiences", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "title",            limit: 255
    t.string   "affiliation",      limit: 255
    t.string   "location",         limit: 255
    t.text     "tasks",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "affiliation_link", limit: 255
  end

  add_index "experiences", ["affiliation_link"], name: "index_experiences_on_affiliation_link", using: :btree

  create_table "facets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "value",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  add_index "facets", ["slug"], name: "index_facets_on_slug", using: :btree

  create_table "favorite_things", force: :cascade do |t|
    t.integer  "favorite_id", limit: 4
    t.string   "thing",       limit: 255
    t.string   "link",        limit: 255
    t.integer  "sort",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_things", ["favorite_id"], name: "index_favorite_things_on_favorite_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.string   "favorite_type", limit: 255
    t.integer  "sort",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "url",               limit: 255
    t.boolean  "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "social_icon"
    t.string   "icon_file_name",    limit: 255
    t.string   "icon_content_type", limit: 255
    t.integer  "icon_file_size",    limit: 4
    t.datetime "icon_updated_at"
  end

  add_index "links", ["social_icon"], name: "index_links_on_social_icon", using: :btree
  add_index "links", ["visible"], name: "index_links_on_visible", using: :btree

  create_table "recent_games", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "platform",           limit: 255
    t.datetime "started_playing"
    t.string   "url",                limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "amazon_url",         limit: 255
  end

  create_table "tabletop_games", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "expansions", limit: 65535
    t.text     "other_info", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "players",    limit: 255
    t.string   "bgg_url",    limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "handle",     limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
