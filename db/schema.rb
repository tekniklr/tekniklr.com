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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110613062402) do

  create_table "experiences", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "title"
    t.string   "affiliation"
    t.string   "location"
    t.text     "tasks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorite_things", :force => true do |t|
    t.integer  "favorite_id"
    t.string   "thing"
    t.string   "link"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.string   "favorite_type"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "handle"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
