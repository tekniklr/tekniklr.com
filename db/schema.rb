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

ActiveRecord::Schema[6.1].define(version: 2019_01_08_045059) do

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "experiences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "title"
    t.string "affiliation"
    t.string "location"
    t.text "tasks"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "affiliation_link"
    t.index ["affiliation_link"], name: "index_experiences_on_affiliation_link"
  end

  create_table "facets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.index ["slug"], name: "index_facets_on_slug"
  end

  create_table "favorite_things", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "favorite_id"
    t.string "thing"
    t.string "link"
    t.integer "sort"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["favorite_id"], name: "index_favorite_things_on_favorite_id"
  end

  create_table "favorites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "favorite_type"
    t.integer "sort"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.boolean "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "social_icon"
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at"
    t.index ["social_icon"], name: "index_links_on_social_icon"
    t.index ["visible"], name: "index_links_on_visible"
  end

  create_table "recent_games", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "platform"
    t.datetime "started_playing"
    t.string "url"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tabletop_games", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "expansions"
    t.text "other_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "players"
    t.string "bgg_url"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "handle"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "enabled", default: false
  end

end
